FROM node:alpine@sha256:9893caff951dd701298d7404b424e34eeaabe7751b9997399ed7b24daa274403
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
