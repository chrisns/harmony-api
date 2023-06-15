FROM node:18.16.0-alpine@sha256:402b5278a24c69d57a9d978aee94df08dc3fbdc310a78538f5df09b474550ac3
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
