FROM node:18.3.0-alpine@sha256:c43e83491468aabc9a144ca7d30c00d6ecfaa8a3931962d2579702a2b03a6ffd
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
