FROM node:18.16.0-alpine@sha256:f41850f74ff16a33daff988e2ea06ef8f5daeb6fb84913c7df09552a98caba09
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
