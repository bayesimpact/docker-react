FROM node:14.6.0

EXPOSE 80
ENV BIND_HOST=0.0.0.0
CMD ["npm", "start"]
WORKDIR /usr/app

# Install a bunch of node modules that are commonly used.
ADD package.json /usr/app/
RUN yarn install

# TODO(pascal): Understand why the package sometimes installs its own version of @sentry/browser.
RUN rm -rf node_modules/\@types/redux-sentry-middleware/node_modules && sed '/"@sentry\/browser@\^5\.0\.0"/,/^\s*$/{d}' -i yarn.lock

# Add default setup files.
ADD .babelrc server.js webpack.config.js /usr/app/
ADD cfg /usr/app/cfg
