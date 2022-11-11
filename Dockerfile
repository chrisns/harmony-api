FROM node:18.12.1-alpine@sha256:c1685b20cb00ab488dd7c4371973a6f62fc831b765a2b00ea2500466f2a8e74e
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
