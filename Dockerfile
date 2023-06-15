FROM node:18.16.0-alpine@sha256:bae8781c3c63e4c66b41076960a6c702d20c79fdbd202d672743e78a0534b23a
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
