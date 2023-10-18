FROM node:18.18.2-alpine@sha256:dc2dd9d7e92d481d8a0e75623dc033225c1e9f7c5ddb16a5af98c7dc165353f2
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
