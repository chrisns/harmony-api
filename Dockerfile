FROM node:alpine@sha256:db3f9c88223ba2491e7d2846a18efe46ecb4b60bf2bcf4b53cdcd39e5f6888b5
LABEL org.opencontainers.image.source https://github.com/chrisns/harmony-api
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
