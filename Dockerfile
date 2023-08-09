FROM node:18.17.0-alpine@sha256:58878e9e1ed3911bdd675d576331ed8838fc851607aed3bb91e25dfaffab3267
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
