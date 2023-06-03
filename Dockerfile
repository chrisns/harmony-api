FROM node:18.16.0-alpine@sha256:e20a6becb9d1a1daa618e71301f5f271c9071c23a573c40d190b354557e624f5
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
