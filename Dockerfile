FROM node:18.15.0-alpine@sha256:66dc3234284fc77db50674f68cdc3098e99e7d1574141eea8bc4de6b3e3b3eea
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
