FROM node:18.12.1-alpine@sha256:ae6cf743c4c290423e163d8a85db7a08b831aace7e2486e857147f78f0cc34d3
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
