FROM node:18.13.0-alpine@sha256:b3f383c13d71066a4e2380d42f4563ac14ac76b3035a5bea4db84209e14665d5
RUN apk add --no-cache git
WORKDIR /usr/src/app

COPY package.json .
COPY package-lock.json .
RUN npm install --production

COPY app.js .
COPY public public
COPY ./config/config.sample.json /config/config.json

ENV CONFIG_DIR /config

EXPOSE 8282
USER node
CMD [ "npm", "start" ]
