FROM node:latest

# Adds fs-extra to npm and replaces the fs.rename method with the fs.extra
# move method that now automatic chooses what to do (rename/move).
# See https://github.com/npm/npm/issues/9863.
RUN cd $(npm root -g)/npm \
  && npm install fs-extra \
  && sed -i -e s/graceful-fs/fs-extra/ -e s/fs.rename/fs.move/ ./lib/utils/rename.js

WORKDIR /usr/app

# Install a bunch of node modules that are commonly used.
ADD package.json .
RUN npm install
RUN rm package.json
