FROM node:17.8.0-alpine@sha256:cb273bf1e93f431f1e9f28b662f64e5e573c65c47c4f65e3b29d3136e0050f19
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
