FROM node:18.12.1-alpine@sha256:62a6ce21599b3183272e71527c9ce9fae9435195052d358f481eb3d69d3dc6f3
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
