FROM node:17.8.0-alpine@sha256:573a21cc05c2825d068eacacd444fdd046dce3cf1486faf6d65bcf031624f115
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
