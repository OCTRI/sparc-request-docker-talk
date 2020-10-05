# Containerizing SPARCRequest

This repository showcases a method of building and running SPARCRequest as a container. It was presented on Sept. 30th, 2020 at the SPARC Open Source Technical Call. See the [presentation document](PRESENTATION.md) for the points covered.

## Building the images

To build the images first build the [`Dockerfile-base`](Dockerfile-base).

```bash
docker build --file Dockerfile-base --tag my_sparc_request_base .
```

You can optionally specify a [release GitHub tag](https://github.com/sparc-request/sparc-request/releases/).

```bash
docker build --file Dockerfile-base --tag my_sparc_request_base --build-arg SPARC_VERSION=x.x.x .
```

At this point you have a basic SPARCRequest Docker image without customization. The [`Dockerfile`](Dockerfile) provides basic customization which replaces the default configuration files with ones that pull details from environment variables. To build this image run the command:

```bash
docker build --tag my_sparc_request --rm .
```

You now have a image that can be run to set up SPARCRequest. As there are a number of environment variables required to get SPARCRequest running it is easiest to copy the [`env.sample`](env.sample) to `.env` and adjust the values to match your environment.

```bash
cp env.sample .env
```

SPARCRequest provides a number of rake tasks to setup the database which need to do be done before you can run the application. The easiest approach is to run the container from the command line and execute these tasks by hand

```bash
docker run -i -t --env-file=.env --rm my_sparc_request /bin/bash
bundle install && rake db:create && rake db:migrate
```

Finally, we can run the container now the database has been initialized

```bash
docker run -i -t --env-file=.env --rm my_sparc_request /bin/bash
```

Alternatively, you can use [Docker Compose](https://docs.docker.com/compose/) and the provided [`docker-compose.yml`] to bootstrap much of the environment.

## Reproducing the slides

The slides were created with [reveal-md](https://github.com/webpro/reveal-md). To view the presentation run

```bash
npm install -g reveal-md
reveal-md PRESENTATION.md
```

The background picture, [Plasma](https://www.flickr.com/photos/doomlordvekk/2719626258/in/photolist-59jN8U-awvt-2jndSq-aJJ7K4-5YKpqJ-6jabwr-2gh9NJ6-4ERsT2-bv56gt-qbPw2m-eyjbP9-bAfkTW-9mx86a-7cLCxj-oxNJ1T-2kqvg9-vcAvs-6oNTSz-4vdMWj-58J2TF-7rQj8B-5mL3nm-4J73nQ-a4bfoi-a4bfoV-a4e63C-8mCsku-aMiweD-5YrUNg-yGM3p-4jZFcU-6tAbXy-2y1V84-pLGpfN-6oaX1g-gsyChd-qzfC5z-bV5Bmv-9mAksE-4jZFAJ-xnuSnm-dEcfrq-bpZeh-64KEru-28PCYL-5Dpy7Y-56jjC-4vdMTN-4EjCTj-pKaF), was created by [doomlordvekk](https://www.flickr.com/photos/doomlordvekk/), and used under the [Creative Commons license](https://creativecommons.org/licenses/by-nc-nd/2.0/legalcode).
