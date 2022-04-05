FROM node:17.8.0-alpine@sha256:61437e1e517019bd27eb4d3ff6a055096e4a8c048230c2d55ef50d6e970ec608
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
