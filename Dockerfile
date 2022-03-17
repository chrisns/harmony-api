FROM node:17.7.1-alpine@sha256:e0419acec75ab3eb99f74641e82647d10c1da959bbbf007d4e26a170894590c3
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
