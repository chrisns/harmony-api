FROM node:18.15.0-alpine@sha256:ffc770cdc09c9e83cccd99d663bb6ed56cfaa1bab94baf1b12b626aebeca9c10
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
