FROM node:17.7.2-alpine@sha256:b6c95e22965ed1e9b0a2cc1362c3e1b3e25d9d10b7ceacde40cea859f5b3ffb6
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
