FROM node:18.18.1-alpine@sha256:617b85a014faf7aabe0661885a245cf3022e39675661d5795ab6748bb2f20f0f
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
