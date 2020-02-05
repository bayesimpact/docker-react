FROM node:13.7.0

EXPOSE 80
ENV BIND_HOST=0.0.0.0
CMD ["npm", "start"]
WORKDIR /usr/app

# Install a bunch of node modules that are commonly used.
ADD package.json /usr/app/
RUN yarn install

# TODO(pascal): Understand why the package sometimes installs its own version of @sentry/browser.
RUN rm -rf node_modules/\@types/redux-sentry-middleware/node_modules

# Add default setup files.
ADD .babelrc server.js webpack.config.js /usr/app/
ADD cfg /usr/app/cfg
