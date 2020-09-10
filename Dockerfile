FROM node:alpine@sha256:3d1bdb8c2d026003273dd229d6f1ac2252be4d6fb5676a15f987f7e761e254d2
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
