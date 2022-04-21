FROM node:18.0.0-alpine@sha256:505bb54d5a7380b805d68db9822dd20844c0d348f4f96ccc57e1a240cba57236
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
