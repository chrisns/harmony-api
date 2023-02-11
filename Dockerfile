FROM node:18.14.0-alpine@sha256:45748c3443410b052e2123dcffbd67838727394f9aacfd23e0b47afd95434ff5
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
