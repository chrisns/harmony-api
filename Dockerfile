FROM node:18.6.0-alpine@sha256:f79e43537bf50b7dda17cbecf6c6915546a8dc50ed6edad8a70b432d8e30f603
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
