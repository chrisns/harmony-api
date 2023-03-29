FROM node:18.15.0-alpine@sha256:ba40f00025397a744a2c6970fa5ea74d386bc04b600edba6260705f8b4eb3afe
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
