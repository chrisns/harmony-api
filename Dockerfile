FROM node:alpine@sha256:8663740f42a195d2721f950a5f7685a77916875c0b7b36c3e0477efbaf5446e0
LABEL org.opencontainers.image.source https://github.com/chrisns/harmony-api
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
