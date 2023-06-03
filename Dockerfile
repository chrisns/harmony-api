FROM node:18.16.0-alpine@sha256:5850491d7879608eb7f7f7fe5beecd946b8b811356dab83c02699d7d77de61a2
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
