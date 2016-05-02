FROM ubuntu

# Install node and npm latest versions.
RUN apt-get update -qq && apt-get install -qqy software-properties-common && \
  add-apt-repository -y ppa:chris-lea/node.js && \
  apt-get update -qq && apt-get install -qqy nodejs libfontconfig && \
  npm install -g npm && \
  # Adds fs-extra to npm and replaces the fs.rename method with the fs.extra
  # move method that now automatic chooses what to do (rename/move).
  cd $(npm root -g)/npm \
  && npm install fs-extra \
  && sed -i -e s/graceful-fs/fs-extra/ -e s/fs.rename/fs.move/ ./lib/utils/rename.js

WORKDIR /usr/app

# Install a bunch of node modules that are commonly used.
ADD package.json .
RUN npm install
RUN rm package.json
