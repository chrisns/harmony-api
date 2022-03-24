FROM node:17.8.0-alpine@sha256:e4a152d1564f2e89d5fa46d74b9f5a050a601322aa10bc405a32faaf1085c5f0
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
