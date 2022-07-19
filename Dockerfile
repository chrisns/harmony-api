FROM node:18.6.0-alpine@sha256:a1c01a01ecb29c6a8bdfdcd49a887a01efa482334fcd87a3dc9e5bc89fcf74b4
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
