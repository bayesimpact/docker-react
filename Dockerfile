FROM node:15.1.0

EXPOSE 80
ENV BIND_HOST=0.0.0.0
CMD ["npm", "start"]
WORKDIR /usr/app

# TODO(cyrille): Drop this once https://github.com/puppeteer/puppeteer/issues/5835 is resolved.
RUN npm install puppeteer@5.3.0 && rm package-lock.json
# Install a bunch of node modules that are commonly used.
ADD package.json /usr/app/
RUN yarn install

# TODO(pascal): Understand why the package sometimes installs its own version of @sentry/browser.
RUN rm -rf node_modules/\@types/redux-sentry-middleware/node_modules && sed '/"@sentry\/browser@\^5\.0\.0"/,/^\s*$/{d}' -i yarn.lock

# Add default setup files.
ADD .babelrc server.js webpack.config.js /usr/app/
ADD cfg /usr/app/cfg
