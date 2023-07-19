FROM node:18.17.0-alpine@sha256:97ec7c325fa2fade73b35191426e14d0e316f23ad9b0bb1a60559c1ee172a06d
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
