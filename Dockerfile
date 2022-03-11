FROM node:17.7.1-alpine@sha256:dc8b656211740222bcc3a5c90fa6ba5e545f779660c67f5d3f155ff946d05aaa
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
