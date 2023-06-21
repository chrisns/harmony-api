FROM node:18.16.1-alpine@sha256:1d0eb1383b35b675fb5cc0c8f04dccaeeac8e2205902eb8d5dc5feb1f9d8f5d8
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
