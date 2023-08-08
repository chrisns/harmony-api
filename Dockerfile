FROM node:18.17.0-alpine@sha256:4860d89cd9bbb0ebe99a7587fdf29413cafb1b25f7f80918302dfc40eb13fe20
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
