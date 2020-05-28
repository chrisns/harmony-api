var path = require('path')
var mqtt = require('mqtt')
var express = require('express')
var morgan = require('morgan')
var bodyParser = require('body-parser')
var parameterize = require('parameterize')

var configDir = process.env.CONFIG_DIR || './config'
var config = require(configDir + '/config.json')

var HarmonyHubDiscover = require('harmonyhubjs-discover')
var harmony = require('harmonyhubjs-client')

var harmonyHubClients = {}
var harmonyActivitiesCache = {}
var harmonyActivityUpdateInterval = 1 * 60 * 1000 // 1 minute
var harmonyActivityUpdateTimers = {}

var harmonyHubStates = {}
var harmonyStateUpdateInterval = 5 * 1000 // 5 seconds
var harmonyStateUpdateTimers = {}

var harmonyDevicesCache = {}
var harmonyDeviceUpdateInterval = 1 * 60 * 1000 // 1 minute
var harmonyDeviceUpdateTimers = {}

var mqttClient = config.mqtt_options
  ? mqtt.connect(config.mqtt_host, config.mqtt_options)
  : mqtt.connect(config.mqtt_host)
var TOPIC_NAMESPACE = config.topic_namespace || 'harmony-api'

var enableHTTPserver = config.enableHTTPserver !== false

var app = express()
app.use(bodyParser.urlencoded({ extended: false }))
app.use(express.static(path.join(__dirname, 'public')))

var logFormat = "'[:date[iso]] - :remote-addr - :method :url :status :response-time ms - :res[content-length]b'"
app.use(morgan(logFormat))

// Middleware
// Check to make sure we have a harmonyHubClient to connect to
var hasHarmonyHubClient = function (req, res, next) {
  if (Object.keys(harmonyHubClients).length > 0) {
    next()
  } else {
    res.status(500).json({ message: 'No hubs available.' })
  }
}
app.use(hasHarmonyHubClient)

var discover = new HarmonyHubDiscover(61991)

discover.on('online', function (hubInfo) {
  // Triggered when a new hub was found
  console.log('Hub discovered: ' + hubInfo.friendlyName + ' at ' + hubInfo.ip + '.')

  if (hubInfo.ip) {
    harmony(hubInfo.ip).then(function (client) {
      startProcessing(parameterize(hubInfo.friendlyName), client)
    })
  }
})

discover.on('offline', function (hubInfo) {
  // Triggered when a hub disappeared
  console.log('Hub lost: ' + hubInfo.friendlyName + ' at ' + hubInfo.ip + '.')
  if (!hubInfo.friendlyName) { return }
  var hubSlug = parameterize(hubInfo.friendlyName)

  clearInterval(harmonyStateUpdateTimers[hubSlug])
  clearInterval(harmonyActivityUpdateTimers[hubSlug])
  delete (harmonyHubClients[hubSlug])
  delete (harmonyActivitiesCache[hubSlug])
  delete (harmonyHubStates[hubSlug])
})

// Look for hubs:
if (config.hubs) {
  console.log('using config defined hubs', config.hubs)
  config.hubs.forEach(hub => harmony(hub.ip)
    .then(client =>
      startProcessing(parameterize(hub.name), client)
    ))
} else {
  console.log('Starting discovery.')
  discover.start()
}

// mqtt api

mqttClient.on('connect', function () {
  mqttClient.subscribe(TOPIC_NAMESPACE + '/hubs/+/activities/+/command')
  mqttClient.subscribe(TOPIC_NAMESPACE + '/hubs/+/devices/+/command')
  mqttClient.subscribe(TOPIC_NAMESPACE + '/hubs/+/command')
})

mqttClient.on('message', function (topic, message) {
  var activityCommandPattern = new RegExp(/hubs\/(.*)\/activities\/(.*)\/command/)
  var deviceCommandPattern = new RegExp(/hubs\/(.*)\/devices\/(.*)\/command/)
  var currentActivityCommandPattern = new RegExp(/hubs\/(.*)\/command/)
  var activityCommandMatches = topic.match(activityCommandPattern)
  var deviceCommandMatches = topic.match(deviceCommandPattern)
  var currentActivityCommandMatches = topic.match(currentActivityCommandPattern)
  var hubSlug
  var repeat
  var messageComponents

  if (activityCommandMatches) {
    hubSlug = activityCommandMatches[1]
    var activitySlug = activityCommandMatches[2]
    var state = message.toString()

    var activity = activityBySlugs(hubSlug, activitySlug)
    if (!activity) { return }

    if (state === 'on') {
      startActivity(hubSlug, activity.id)
    } else if (state === 'off') {
      off(hubSlug)
    }
  } else if (deviceCommandMatches) {
    hubSlug = deviceCommandMatches[1]
    var deviceSlug = deviceCommandMatches[2]
    messageComponents = message.toString().split(':')
    var command = messageComponents[0]
    repeat = messageComponents[1]

    command = commandBySlugs(hubSlug, deviceSlug, command)
    if (!command) { return }

    sendAction(hubSlug, command.action, repeat)
  } else if (currentActivityCommandMatches) {
    hubSlug = currentActivityCommandMatches[1]
    messageComponents = message.toString().split(':')
    var commandSlug = messageComponents[0]
    repeat = messageComponents[1]

    var hubState = harmonyHubStates[hubSlug]
    if (!hubState) { return }

    activity = activityBySlugs(hubSlug, hubState.current_activity.slug)
    if (!activity) { return }

    command = activity.commands[commandSlug]
    if (!command) { return }

    sendAction(hubSlug, command.action, repeat)
  }
})

function startProcessing (hubSlug, harmonyClient) {
  harmonyHubClients[hubSlug] = harmonyClient

  // update the list of activities
  updateActivities(hubSlug)
  // then do it on the set interval
  clearInterval(harmonyActivityUpdateTimers[hubSlug])
  harmonyActivityUpdateTimers[hubSlug] = setInterval(function () { updateActivities(hubSlug) }, harmonyActivityUpdateInterval)

  // update the state
  updateState(hubSlug)
  // update the list of activities on the set interval
  clearInterval(harmonyStateUpdateTimers[hubSlug])
  harmonyStateUpdateTimers[hubSlug] = setInterval(function () { updateState(hubSlug) }, harmonyStateUpdateInterval)

  // update devices
  updateDevices(hubSlug)
  // update the list of devices on the set interval
  clearInterval(harmonyDeviceUpdateTimers[hubSlug])
  harmonyDeviceUpdateTimers[hubSlug] = setInterval(function () { updateDevices(hubSlug) }, harmonyDeviceUpdateInterval)
}

function updateActivities (hubSlug) {
  var harmonyHubClient = harmonyHubClients[hubSlug]

  if (!harmonyHubClient) { return }
  console.log('Updating activities for ' + hubSlug + '.')

  try {
    harmonyHubClient.getActivities().then(function (activities) {
      var foundActivities = {}
      activities.some(function (activity) {
        foundActivities[activity.id] = { id: activity.id, slug: parameterize(activity.label), label: activity.label, isAVActivity: activity.isAVActivity }
        Object.defineProperty(foundActivities[activity.id], 'commands', {
          enumerable: false,
          writeable: true,
          value: getCommandsFromControlGroup(activity.controlGroup)
        })
      })
      harmonyActivitiesCache[hubSlug] = foundActivities
    })
  } catch (err) {
    console.log('ERROR: ' + err.message)
  }
}

function updateState (hubSlug) {
  var harmonyHubClient = harmonyHubClients[hubSlug]

  if (!harmonyHubClient) { return }
  console.log('Updating state for ' + hubSlug + '.')

  // save for comparing later after we get the true current state
  var previousActivity = currentActivity(hubSlug)

  try {
    harmonyHubClient.getCurrentActivity().then(function (activityId) {
      var data = { off: true }

      var activity = harmonyActivitiesCache[hubSlug][activityId]
      var commands = Object.keys(activity.commands).map(function (commandSlug) {
        return activity.commands[commandSlug]
      })

      if (activityId !== -1 && activity) {
        data = { off: false, current_activity: activity, activity_commands: commands }
      } else {
        data = { off: true, current_activity: activity, activity_commands: commands }
      }

      // cache state for later
      harmonyHubStates[hubSlug] = data

      if (!previousActivity || (activity.id !== previousActivity.id)) {
        publish('hubs/' + hubSlug + '/' + 'current_activity', activity.slug, { retain: true })
        publish('hubs/' + hubSlug + '/' + 'state', activity.id === -1 ? 'off' : 'on', { retain: true })

        for (var i = 0; i < cachedHarmonyActivities(hubSlug).length; i++) {
          var activities = cachedHarmonyActivities(hubSlug)
          var cachedActivity = activities[i]

          if (activity === cachedActivity) {
            publish('hubs/' + hubSlug + '/' + 'activities/' + cachedActivity.slug + '/state', 'on', { retain: true })
          } else {
            publish('hubs/' + hubSlug + '/' + 'activities/' + cachedActivity.slug + '/state', 'off', { retain: true })
          }
        }
      }
    })
  } catch (err) {
    console.log('ERROR: ' + err.message)
  }
}

function updateDevices (hubSlug) {
  var harmonyHubClient = harmonyHubClients[hubSlug]

  if (!harmonyHubClient) { return }
  console.log('Updating devices for ' + hubSlug + '.')
  try {
    harmonyHubClient.getAvailableCommands().then(function (commands) {
      var foundDevices = {}
      commands.device.some(function (device) {
        var deviceCommands = getCommandsFromControlGroup(device.controlGroup)
        foundDevices[device.id] = { id: device.id, slug: parameterize(device.label), label: device.label }
        Object.defineProperty(foundDevices[device.id], 'commands', {
          enumerable: false,
          writeable: true,
          value: deviceCommands
        })
      })

      harmonyDevicesCache[hubSlug] = foundDevices
    })
  } catch (err) {
    console.log('Devices ERROR: ' + err.message)
  }
}

function getCommandsFromControlGroup (controlGroup) {
  var deviceCommands = {}
  controlGroup.some(function (group) {
    group.function.some(function (func) {
      var slug = parameterize(func.label)
      deviceCommands[slug] = { name: func.name, slug: slug, label: func.label }
      Object.defineProperty(deviceCommands[slug], 'action', {
        enumerable: false,
        writeable: true,
        value: func.action.replace(/\:/g, '::') // eslint-disable-line no-useless-escape
      })
    })
  })
  return deviceCommands
}

function cachedHarmonyActivities (hubSlug) {
  var activities = harmonyActivitiesCache[hubSlug]
  if (!activities) { return [] }

  return Object.keys(harmonyActivitiesCache[hubSlug]).map(function (key) {
    return harmonyActivitiesCache[hubSlug][key]
  })
}

function currentActivity (hubSlug) {
  var harmonyHubClient = harmonyHubClients[hubSlug]
  var harmonyHubState = harmonyHubStates[hubSlug]
  if (!harmonyHubClient || !harmonyHubState) { return null }

  return harmonyHubState.current_activity
}

function activityBySlugs (hubSlug, activitySlug) {
  var activity
  cachedHarmonyActivities(hubSlug).some(function (a) {
    if (a.slug === activitySlug) {
      activity = a
      return true
    }
  })

  return activity
}

function activityCommandsBySlugs (hubSlug, activitySlug) {
  var activity = activityBySlugs(hubSlug, activitySlug)

  if (activity) {
    return Object.keys(activity.commands).map(function (commandSlug) {
      return activity.commands[commandSlug]
    })
  }
}

function cachedHarmonyDevices (hubSlug) {
  var devices = harmonyDevicesCache[hubSlug]
  if (!devices) { return [] }

  return Object.keys(harmonyDevicesCache[hubSlug]).map(function (key) {
    return harmonyDevicesCache[hubSlug][key]
  })
}

function deviceBySlugs (hubSlug, deviceSlug) {
  var device
  cachedHarmonyDevices(hubSlug).some(function (d) {
    if (d.slug === deviceSlug) {
      device = d
      return true
    }
  })

  return device
}

function commandBySlugs (hubSlug, deviceSlug, commandSlug) {
  var command
  var device = deviceBySlugs(hubSlug, deviceSlug)
  if (device) {
    if (commandSlug in device.commands) {
      command = device.commands[commandSlug]
    }
  }

  return command
}

function off (hubSlug) {
  var harmonyHubClient = harmonyHubClients[hubSlug]
  if (!harmonyHubClient) { return }

  harmonyHubClient.turnOff().then(function () {
    updateState(hubSlug)
  })
}

function startActivity (hubSlug, activityId) {
  var harmonyHubClient = harmonyHubClients[hubSlug]
  if (!harmonyHubClient) { return }

  harmonyHubClient.startActivity(activityId).then(function () {
    updateState(hubSlug)
  })
}

function sendAction (hubSlug, action, repeat) {
  repeat = Number.parseInt(repeat) || 1
  var harmonyHubClient = harmonyHubClients[hubSlug]
  if (!harmonyHubClient) { return }

  var pressAction = 'action=' + action + ':status=press:timestamp=0'
  var releaseAction = 'action=' + action + ':status=release:timestamp=55'
  for (var i = 0; i < repeat; i++) {
    harmonyHubClient.send('holdAction', pressAction).then(function () {
      harmonyHubClient.send('holdAction', releaseAction)
    })
  }
}

function publish (topic, message, options) {
  topic = TOPIC_NAMESPACE + '/' + topic
  mqttClient.publish(topic, message, options)
}

app.get('/_ping', function (req, res) {
  res.send('OK')
})

app.get('/', function (req, res) {
  res.sendfile('index.html')
})

app.get('/hubs', function (req, res) {
  res.json({ hubs: Object.keys(harmonyHubClients) })
})

app.get('/hubs/:hubSlug/activities', function (req, res) {
  var hubSlug = req.params.hubSlug
  var harmonyHubClient = harmonyHubClients[hubSlug]

  if (harmonyHubClient) {
    res.json({ activities: cachedHarmonyActivities(hubSlug) })
  } else {
    res.status(404).json({ message: 'Not Found' })
  }
})

app.get('/hubs/:hubSlug/activities/:activitySlug/commands', function (req, res) {
  var commands = activityCommandsBySlugs(req.params.hubSlug, req.params.activitySlug)

  if (commands) {
    res.json({ commands: commands })
  } else {
    res.status(404).json({ message: 'Not Found' })
  }
})

app.get('/hubs/:hubSlug/devices', function (req, res) {
  var hubSlug = req.params.hubSlug
  var harmonyHubClient = harmonyHubClients[hubSlug]

  if (harmonyHubClient) {
    res.json({ devices: cachedHarmonyDevices(hubSlug) })
  } else {
    res.status(404).json({ message: 'Not Found' })
  }
})

app.get('/hubs/:hubSlug/devices/:deviceSlug/commands', function (req, res) {
  var hubSlug = req.params.hubSlug
  var deviceSlug = req.params.deviceSlug
  var device = deviceBySlugs(hubSlug, deviceSlug)

  if (device) {
    var commands = Object.keys(device.commands).map(function (commandSlug) {
      return device.commands[commandSlug]
    })
    res.json({ commands: commands })
  } else {
    res.status(404).json({ message: 'Not Found' })
  }
})

app.get('/hubs/:hubSlug/status', function (req, res) {
  var hubSlug = req.params.hubSlug
  var harmonyHubClient = harmonyHubClients[hubSlug]

  if (harmonyHubClient) {
    res.json(harmonyHubStates[hubSlug])
  } else {
    res.status(404).json({ message: 'Not Found' })
  }
})

app.get('/hubs/:hubSlug/commands', function (req, res) {
  var hubSlug = req.params.hubSlug
  var activitySlug = harmonyHubStates[hubSlug].current_activity.slug

  var commands = activityCommandsBySlugs(hubSlug, activitySlug)
  if (commands) {
    res.json({ commands: commands })
  } else {
    res.status(404).json({ message: 'Not Found' })
  }
})

app.post('/hubs/:hubSlug/commands/:commandSlug', function (req, res) {
  var hubSlug = req.params.hubSlug
  var activitySlug = harmonyHubStates[hubSlug].current_activity.slug
  var commandSlug = req.params.commandSlug

  var activity = activityBySlugs(hubSlug, activitySlug)
  if (activity && commandSlug in activity.commands) {
    sendAction(hubSlug, activity.commands[commandSlug].action, req.query.repeat)

    res.json({ message: 'ok' })
  } else {
    res.status(404).json({ message: 'Not Found' })
  }
})

app.put('/hubs/:hubSlug/off', function (req, res) {
  var hubSlug = req.params.hubSlug
  var harmonyHubClient = harmonyHubClients[hubSlug]

  if (harmonyHubClient) {
    off(hubSlug)
    res.json({ message: 'ok' })
  } else {
    res.status(404).json({ message: 'Not Found' })
  }
})

// DEPRECATED
app.post('/hubs/:hubSlug/start_activity', function (req, res) {
  var activity = activityBySlugs(req.params.hubSlug, req.query.activity)

  if (activity) {
    startActivity(req.params.hubSlug, activity.id)

    res.json({ message: 'ok' })
  } else {
    res.status(404).json({ message: 'Not Found' })
  }
})

app.post('/hubs/:hubSlug/activities/:activitySlug', function (req, res) {
  var activity = activityBySlugs(req.params.hubSlug, req.params.activitySlug)

  if (activity) {
    startActivity(req.params.hubSlug, activity.id)

    res.json({ message: 'ok' })
  } else {
    res.status(404).json({ message: 'Not Found' })
  }
})

app.post('/hubs/:hubSlug/devices/:deviceSlug/commands/:commandSlug', function (req, res) {
  var command = commandBySlugs(req.params.hubSlug, req.params.deviceSlug, req.params.commandSlug)

  if (command) {
    sendAction(req.params.hubSlug, command.action, req.query.repeat)

    res.json({ message: 'ok' })
  } else {
    res.status(404).json({ message: 'Not Found' })
  }
})

app.get('/hubs_for_index', function (req, res) {
  var output = ''

  Object.keys(harmonyHubClients).forEach(function (hubSlug) {
    output += '<h3 class="hub-name">' + hubSlug.replace('-', ' ') + '</h3>'
    output += '<p><span class="method">GET</span> <a href="/hubs/' + hubSlug + '/status">/hubs/' + hubSlug + '/status</a></p>'
    output += '<p><span class="method">GET</span> <a href="/hubs/' + hubSlug + '/activities">/hubs/' + hubSlug + '/activities</a></p>'
    output += '<p><span class="method">GET</span> <a href="/hubs/' + hubSlug + '/commands">/hubs/' + hubSlug + '/commands</a></p>'
    cachedHarmonyActivities(hubSlug).forEach(function (activity) {
      path = '/hubs/' + hubSlug + '/activities/' + activity.slug + '/commands'
      output += '<p><span class="method">GET</span> <a href="' + path + '">' + path + '</a></p>'
    })
    output += '<p><span class="method">GET</span> <a href="/hubs/' + hubSlug + '/devices">/hubs/' + hubSlug + '/devices</a></p>'
    cachedHarmonyDevices(hubSlug).forEach(function (device) {
      path = '/hubs/' + hubSlug + '/devices/' + device.slug + '/commands'
      output += '<p><span class="method">GET</span> <a href="' + path + '">' + path + '</a></p>'
    })
  })

  res.send(output)
})

if (enableHTTPserver) {
  app.listen(process.env.PORT || 8282)
}
