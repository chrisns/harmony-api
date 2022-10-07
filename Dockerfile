FROM node:18.10.0-alpine@sha256:24f5462c275694fd09a134300a66f64c42898b05c0fdd223581504bfc05d48bb
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
