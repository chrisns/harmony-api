FROM node:17.8.0-alpine@sha256:c6fa8b1ea6d027c8fcbe33dee878e5b01c172ea65f3c1aed308008ebbc9db0b2
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
