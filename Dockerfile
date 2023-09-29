FROM node:18.18.0-alpine@sha256:63f8799bb0a1cf19b420e08ba2cfd53e22ed71f0b4434026c6c21c1d06d34ce5
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
