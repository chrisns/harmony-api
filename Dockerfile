FROM node:17.7.2-alpine@sha256:d211f6788222aac6a871bc0ada4b1e5e00c42c615d32b80b38548f04ebafd05a
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
