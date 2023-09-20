FROM node:18.18.0-alpine@sha256:c8cda7c7001d3a0011f632d27407d17abd2517ddf63a5b9f2cf2201f71f9e3f7
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
