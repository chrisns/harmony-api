FROM node:18.14.0-alpine@sha256:bfc56a6ea052f1993f985c01f6b0b71625110cbafb491ec4c7e26e61ad28003e
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
