FROM node:18.15.0-alpine@sha256:50437be86204dbc5e931d0c5491f16a9856df6e2101f3001c687e51b875ec320
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
