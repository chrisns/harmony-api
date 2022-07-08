FROM node:18.5.0-alpine@sha256:e479d86de1ef8403adda6800733a7f8d18df4f3c1c2e68ba3e2bc05fdea9de20
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
