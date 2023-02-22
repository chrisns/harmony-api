FROM node:18.14.1-alpine@sha256:e0a779479fca9cf43cae2852291bee70e730ae3ad27fea1211060bd344b696b8
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
