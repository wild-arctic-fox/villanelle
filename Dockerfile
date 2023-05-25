FROM node:18-alpine

ENV APPLICATION_NAME=patrick-jane-tea-app

RUN npm install -g pnpm

WORKDIR /usr/src/app

COPY package.json pnpm-lock.yaml ./

RUN pnpm install --frozen-lockfile

COPY . .

EXPOSE 7410

RUN pnpm build

CMD [ "pnpm", "start" ]