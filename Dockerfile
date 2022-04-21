FROM node:18.0.0-alpine@sha256:1e51561b49be84676669cdc824069546171ed0a6a00eb0ee4a56d490fb8743a8
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
