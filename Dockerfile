FROM node:17.3.1-alpine@sha256:7ef8e673a9ea7b1dfaae292bf8faf549bb81ba60f68087454cef143698bdf2c4
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
