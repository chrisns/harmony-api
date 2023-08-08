FROM node:18.17.0-alpine@sha256:e98b96c93214f1ac4253cc1741aa96933947ca904ba0dc750ba0e33016d18521
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
