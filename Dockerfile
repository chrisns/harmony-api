FROM node:alpine@sha256:e810cbc3cdddd9b43bd1feb2cbf1c4536d3c7e388cbeb86dce18f7b68977e724
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
