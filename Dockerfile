FROM node:18.14.2-alpine@sha256:0d2712ac2b2c1149391173de670406f6e3dbdb1b2ba44e8530647e623e0e1b17
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
