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
`/usr/app/src/entry.js` or `/usr/app/src/entry.jsx`.


## Local testing

To test this image locally before publishing, build it with

`docker build -t bayesimpact/react-base:latest .`

Then simply rebuild your images that are based on `react-base`.

## Continuous integration

When running the CI on a branch, CircleCI builds the docker image. On the default branch, it will also run a job in each dependant repos. To add a new repo, do the following:

### Configure your repo's build

Add a job `test-for-base-change` that runs your tests that depends on the version of the bayesimpact/react-base docker image.

This job must use the `REACT_BASE_TAG` environment variable as the docker image tag.

#### Using REACT_BASE_TAG (required)

If you build an image on top of `bayesimpact/react-base`, just replace your FROM command with
```Dockerfile
ARG REACT_BASE_TAG
FROM bayesimpact/react-base:${REACT_BASE_TAG:-latest}
```

And run `docker build --build-arg REACT_BASE_TAG <your_usual_build>`.

You can also do this using `docker-compose`. In your `docker-compose.yml`:
```yaml
service_name:
    ...
    build:
      ...
      args:
        ...
        - REACT_BASE_TAG
```
And then run `docker-compose build service_name`

#### Using Github Status (optional)

To tell docker-react that the build succeeded on the dependant repo, you must update a [Github status check](https://docs.github.com/en/free-pro-team@latest/github/collaborating-with-issues-and-pull-requests/about-status-checks) on docker-react. This is completely optional (the corresponding check will remain "pending" if you don't do it, but it's not blocking anything).

Once the dependant repo considers the build successful, it should call the status check API with the following HTTPS request:

```bash
curl -u "$GITHUB_STATUS_TOKEN" "$STATUS_UPDATE_URL" \
  -XPOST --data '{"status": "success", "context": "'$STATUS_CONTEXT'"}'
```

`GITHUB_STATUS_TOKEN` should be given as basic authentication with a [Github access token](https://github.com/settings/tokens), with `repo:status` access on `bayesimpact/docker-react`. The other environment variables (`STATUS_UPDATE_URL` and `STATUS_CONTEXT`) are directly given to the dependent repo CircleCI build.

### Configuring docker-react build

Add a job in the `commit` workflow
```yaml
- check-dependant-repo:
    requires:
      - build
    repo: <your_repo_name>
    owner: <your_repo_owner> # not needed if it's bayesimpact
```

## Publishing the image

The public image on https://hub.docker.com/r/bayesimpact/react-base/ gets updated automatically. You just have to edit the `Dockerfile` and push to github. Always have someone review your code before you push to the default branch.
