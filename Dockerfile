FROM node:18.12.1-alpine@sha256:c7d45b801406fe733c5893c03dc47fd5fa703f37d6893f96c3acf38286bd88b0
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
