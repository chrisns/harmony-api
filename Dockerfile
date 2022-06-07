FROM node:18.3.0-alpine@sha256:36e8741b663ce72183be42d234833c02ab3e620f175cd3a720f37c9846a67245
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
