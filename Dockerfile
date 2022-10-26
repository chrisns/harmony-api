FROM node:18.11.0-alpine@sha256:d1f183e67fdb22c1208bd9f20d498cd2a4dbfc79ac5a72865162fc0bf7ca966c
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
