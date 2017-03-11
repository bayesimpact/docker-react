# TODO: upgrade to xenial.
FROM ubuntu:trusty

# Install node and npm latest versions.
RUN apt-get update -qq && apt-get install -qqy software-properties-common curl && \
  curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
  apt-get install -qqy nodejs libfontconfig && \
  # Remove the install source for NPM as it's not very reliable.
  rm /etc/apt/sources.list.d/nodesource.list && \
  npm install -g npm && \
  # Adds fs-extra to npm and replaces the fs.rename method with the fs.extra
  # move method that now automatic chooses what to do (rename/move).
  # See https://github.com/npm/npm/issues/9863.
  cd $(npm root -g)/npm \
  && npm install fs-extra \
  && sed -i -e s/graceful-fs/fs-extra/ -e s/fs.rename/fs.move/ ./lib/utils/rename.js

EXPOSE 80
ENV BIND_HOST=0.0.0.0
CMD ["npm", "start"]
WORKDIR /usr/app

# Install a bunch of node modules that are commonly used.
ADD package.json server.js webpack.config.js cfg /usr/app/
RUN npm install
RUN rm package.json
