FROM node:alpine
RUN apk update && apk add --no-cache make git

WORKDIR /usr/app
COPY ./ /usr/app

RUN npm install 

RUN npx create-react-app my-app \
    npm init react-app my-app \
    yarn create react-app my-app \
    cd /my-app \
    yarn start  \
    yarn test \
    yarn build \
    yarn eject