FROM node:18.3.0-alpine@sha256:7ab82182ec72ea2042e29f40fd2d7badf3023302928600803e2c158be85aee94
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
