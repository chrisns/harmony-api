FROM node:18.2.0-alpine@sha256:1d4fe66446508973e747fbc3cc86ca266c2a13510f6e8e9bb9f1a244dc984f18
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
