FROM node:alpine@sha256:cf4fbc268ed5118f97114d7bb3dd6dd01728c55ec9d7ec10bb1231b0084e0bba
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
