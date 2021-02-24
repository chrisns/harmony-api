FROM node:alpine@sha256:6d19f8a9793b6f4d134a5f1c5280386ae6a95a6358206c455f40367a1e8323f6
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
