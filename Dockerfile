FROM node:18.12.1-alpine@sha256:7bd754b52b9a2634a5060b4f737409a3e771b5d062e2e860b9c74363614759e2
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
