FROM node:17.9.0-alpine@sha256:e7930abb2b33c8c7fa1a6dd1addd40cb26104c80f2e2a5d59d480aa2843bbed1
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
