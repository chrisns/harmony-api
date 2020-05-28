FROM node:alpine@sha256:c3f1683ce9d265e46a414cc2e4bc4e2076a8545e05a3ec2d127450830adccb1a
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
