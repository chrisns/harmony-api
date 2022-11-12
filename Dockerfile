FROM node:18.12.1-alpine@sha256:e98e4e4eaef022a455a78a4c58e54b51e2cbdb65ccd30dc9a06fe342fb5c2d89
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
