FROM node:18.17.1-alpine@sha256:05aae879a3a579d54e9a0742c34f2562c56ac7bdb1bd985b1ff9f29f40822324
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
