FROM node:18.11.0-alpine@sha256:7d74f7ef0433aca0c9f646031c84be459fc073d7a095545553a435fe1b1bc01e
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
