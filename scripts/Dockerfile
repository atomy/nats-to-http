FROM node:25-alpine

RUN apk add --update icu-data-full npm
RUN npm install -g npm

COPY .. /app

RUN cd /app && npm install

WORKDIR "/app"

CMD [ "node", "relay.js" ]
