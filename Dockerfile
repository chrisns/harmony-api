FROM node:alpine@sha256:c81d659f51a11aea6d73598fce064cf087b21caf9046fbf34530d9f1d43c8ec8
RUN apk add --no-cache git
WORKDIR /usr/src/app

COPY package.json .
COPY package-lock.json .
RUN npm install

COPY app.js .
COPY public .
COPY ./config/config.sample.json /config/config.json

ENV CONFIG_DIR /config

EXPOSE 8282
USER node
CMD [ "npm", "start" ]
