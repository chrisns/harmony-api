FROM node:18.16.0-alpine@sha256:1ccc70acda680aa4ba47f53e7c40b2d4d6892de74817128e0662d32647dd7f4d
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
