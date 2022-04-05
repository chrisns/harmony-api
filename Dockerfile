FROM node:17.8.0-alpine@sha256:3981a6d3b7aa40192f7030f344f4e6f7ea6e932ab948e417407d6af2ca007226
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
