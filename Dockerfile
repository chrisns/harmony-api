FROM node:18.17.0-alpine@sha256:751a2934c5d784d1d4b3feb189bf1dd62bf08918cf6bb3e9f06eead6df71a0f3
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
