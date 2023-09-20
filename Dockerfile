FROM node:18.18.0-alpine@sha256:619ce27eb37c7c0476bd518085bf1ba892e2148fc1ab5dbaff2f20c56e50444d
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
