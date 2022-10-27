FROM node:18.12.0-alpine@sha256:1f09c210a17508d34277971b19541a47a26dc5a641dedc03bd28cff095052996
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
