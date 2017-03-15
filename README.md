This is the source of the Docker image
[bayesimpact/react-base](https://hub.docker.com/r/bayesimpact/react-base/).

[![](https://images.microbadger.com/badges/image/bayesimpact/react-base.svg)](https://hub.docker.com/r/bayesimpact/react-base/)

It is used to speed up setup when developping a project using React with npm.
It prepares a container with latest versions of:
* node
* npm
* WebPack
* React
* EsLint
* a good deal of node modules pre-installed.


## Environments

It bootstraps an application with three environments:
* **dev**, an environment to develop on a local machine, hot reload components, etc.
* **dist**, an environment releasing only the code that is used packaged for distribution.
* **test**, an environment to run automated tests.

Do not use this image for production, you should compile your React anyway and
only push the result of the `dist` folder when running `npm run dist`.

### Dev

The default environment is `dev` and this image provides a server (started by
the default command `npm start`) that serves from port 80. As with all Docker
containers we suggest you do some port forwarding when creating an image
(`docker run -p 3000:80`).


## Setup and configuration

Use it as a base and mount or copy your actual application to `/usr/app`.

The webpack configurations are in `/usr/app/cfg/` (`base.js`, `dev.js`, …). To
modify those configs you need to overwrite them by copying a new file on top of
it.

The actual source of the app should be mounted in `/usr/app/src`, more
specifically the webpack entrypoint for the app is taken by default from
`/usr/app/src/components/index.js` or `/usr/app/src/components/index.jsx`.


## Local testing

To test this image locally before publishing, build it with

`docker build -t bayesimpact/react-base:latest .`

Then simply rebuild your images that are based on `react-base`.


## Publishing the image

The public image on https://hub.docker.com/r/bayesimpact/react-base/ gets updated automatically. You just have to edit the `Dockerfile` and push to github. Always have someone review your code before you push to master.
