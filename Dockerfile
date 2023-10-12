FROM node:18.18.1-alpine@sha256:f0d7c41a0614bbf3f7aa9960d9e1a43fc24373268de4c21cc8a346ec0165f993
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
