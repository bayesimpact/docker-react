This is the source of the Docker image
[bayesimpact/react-base](https://hub.docker.com/r/bayesimpact/react-base/).

[![](https://images.microbadger.com/badges/image/bayesimpact/react-base.svg)](https://hub.docker.com/r/bayesimpact/react-base/)

It is used to speed up setup when developping a project using React with npm.
It prepares a container with node and npm latest versions as well as a good
deal of node modules pre-installed.

Use it as a base and put your actual application in `/usr/app`.

If you use this image for production (but you should compile your React
anyway), beware that there might be many node modules that you won't need at
all.


## Local testing

To test this image locally before publishing, build it with

`docker build -t bayesimpact/react-base:latest .`

Then simply rebuild your images that are based on `react-base`.


## Publishing the image

The public image on https://hub.docker.com/r/bayesimpact/react-base/ gets updated automatically. You just have to edit the `Dockerfile` and push to github. Always have someone review your code before you push to master.
