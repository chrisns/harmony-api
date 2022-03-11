FROM node:17.7.1-alpine@sha256:82c0402acb72a3c8f02a4ae43543f710d9868d5980de7c273646c9d9b4cd74f7
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
