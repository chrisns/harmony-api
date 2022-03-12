FROM node:17.7.1-alpine@sha256:6a016b0fd228faf31464ad7d12edf94fbd3fb5102f40c4cce3c0d2af0ee04800
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
