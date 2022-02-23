FROM node:17.6.0-alpine@sha256:4cd7597eff69e9e4603f926e21a2cfa9dff8c49fca72914a4e6428ebf9bc91d6
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
