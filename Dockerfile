FROM node:15.13.0

EXPOSE 80
ENV BIND_HOST=0.0.0.0
CMD ["npm", "start"]
WORKDIR /usr/app

# List of apps for Chrome install, see https://github.com/puppeteer/puppeteer/issues/290#issuecomment-322838700
RUN apt-get update && apt-get install -qqy --no-install-recommends gconf-service libasound2 \
    libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 \
    libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 \
    libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 \
    libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation \
    libappindicator1 libnss3 lsb-release xdg-utils wget

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
