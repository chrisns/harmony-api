FROM node:18.3.0-alpine@sha256:255769febc7362f4ab4e6fc8fbcc77e310eeba0dea0d0b638dd3c8328fb157d4
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
