---
title: "SPARC in a bottle"
theme: night
revealOptions:
    transition: 'slide'
---

<!-- .slide: data-background-image="assets/plasma.jpg" -->
## SPARC in a bottle

Containerizing SPARCRequest

---

## Disclaimer

_I have no relevant personal/professional/financial relationship with products or companies presented today._

---

## `whoami`

```
$ finger -s benton
Email            Name         Idle  Login  Office
benton@ohsu.edu  Erik Benton   28d  Aug 31 OHSU OCTRI CRI Apps
```
Clinical Research Informatics - Applications
<!-- .element: class="fragment" data-fragment-index="3" -->

Oregon Clinical & Translational Research Institute
<!-- .element: class="fragment" data-fragment-index="2" -->

Oregon Health & Science University
<!-- .element: class="fragment" data-fragment-index="1" -->
---

## Container crash course
_(What is a container?)_

* Not a Virtual Machine <!-- .element: class="fragment" data-fragment-index="1" -->
* Virtualizes the OS and network but not hardware <!-- .element: class="fragment" data-fragment-index="2" -->
* Keeps things smaller, faster and portable <!-- .element: class="fragment" data-fragment-index="3" -->

Note:
Containers are a method of packaging an application and its dependencies into a single artifact that can be run on any system.

As opposed to a VM containers rely on the underlying host OS, making them more lightweight and quicker to run. Better resource allocation where as a hypervisor must partition its resources to each VM, containers use only the resources necessary

Security: VMs have more stringent security controls due to the complete independence of resource, but containers if run correctly can offer many of the same protections

---

## Handy Definitions

* Image - Executable package that contains all the necessary components of an application
* Container - A running instance of an image

---

![Docker logo](https://www.docker.com/sites/default/files/d8/2019-07/Moby-logo.png)

Docker

Note: Main developers/drivers of container technologies. Started in 2013 provided tools to take advantage of a number of Linux kernel features to make containers a reality and easy to use by a wide audience.

---

## Why use it?

Consistency of environment and dependencies
<!-- .element: class="fragment" data-fragment-index="1" -->

Better resource utilization
<!-- .element: class="fragment" data-fragment-index="2" -->

Ease of deployment
<!-- .element: class="fragment" data-fragment-index="3" -->

Simplify developer experience
<!-- .element: class="fragment" data-fragment-index="4" -->

---

## Why use it for SPARCRequest?

Note: Stack is not consistent with our other tools. Packaging as an image makes it easier to run with all the necessary tools included

Simplify packaging and deployment to servers

Environment isolation

---

## How do we use it?

---

Two image build processes
* octri.ohsu.edu/sparc-request-base
* octri.ohsu.edu/sparc-request

---

octri.ohsu.edu/sparc-request-base
```docker [1|6-15|17-21|25-27|29-30]
FROM ruby:2.5

ARG SPARC_VERSION=3.7.1
ENV LANG=en_US.UTF-8
# Add dependencies for Rails and the Paperclip gem
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg \
      | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" \
      | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y \
    ghostscript \
    imagemagick \
    yarn \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -o sparc-request.tgz \
    https://github.com/sparc-request/sparc-request/archive/release-${SPARC_VERSION}.tar.gz && \
  tar xvf sparc-request.tgz && \
  mv sparc-request-release-${SPARC_VERSION} /sparc && \
  rm sparc-request.tgz

WORKDIR /sparc

RUN gem install bundler && \
    bundle install --without="development test" && \
    yarn install

EXPOSE 3000
CMD ["rails", "s", "-b", "0.0.0.0"]

```

Note:

* Base image has no customization just vanilla build instructions
* Checkout tag from [Github](https://github.com/sparc-request/sparc-request/releases/latest)

---

octri.ohsu.edu/sparc-request

```docker [1|3-4|5-8|9-11|12]
FROM octri.ohsu.edu/sparc_request_base:3.7.1

COPY ./deps/sparc/assets/images/blank_logo.jpg /sparc/app/assets/images/logos/blank_logo.jpg
COPY ./deps/sparc/assets/images/octri_logo.jpg /sparc/app/assets/images/logos/octri_logo.jpg
COPY ./deps/sparc/database.yml /sparc/config/database.yml
COPY ./deps/sparc/development.rb /sparc/config/environments/development.rb
COPY ./deps/sparc/staging.rb /sparc/config/environments/staging.rb
COPY ./deps/sparc/production.rb /sparc/config/environments/production.rb
COPY ./deps/sparc/locales/*.yml /sparc/config/locales/
COPY ./deps/sparc/reports/*.rb /sparc/app/lib/reports/
COPY ./deps/sparc/tasks/*.rake /sparc/lib/tasks/
COPY ./deps/sparc/remote_service_notifier_job.rb /sparc/app/jobs/remote_service_notifier_job
...
```

Note: Maintain a development branch. Mostly back-ports of fixes, reports,  localization files, etc.

---

Jenkins CI
1. Build base image
1. Build OCTRI image
1. Merge all changes to main branch prior to release
1. Job builds main branch
1. Deploy to production

Note:

* OCTRI image is built with every commit to the `development` branch
* Maintaining separate `development` and `master` branches allows us to maintain versions and cherry-pick commits into our production instance

---

![Kubernetes](https://raw.githubusercontent.com/kubernetes/kubernetes/master/logo/logo.png)
<!-- .element: style="height: 500px; width:500px; margin: auto;" -->
Kubernetes


Note: Beyond simply running the container we use a container orchestration system, in this case a Kubernetes cluster, which runs on both VMs and physical systems. This ensures that the application is available and scaled appropriately.

---

## What we learned

External configuration is crucial
<!-- .element: class="fragment" data-fragment-index="1" -->

SPARCRequest is opinionated
<!-- .element: class="fragment" data-fragment-index="2" -->

Delayed Jobs require their own container
<!-- .element: class="fragment" data-fragment-index="3" -->

Ruby on Rails make customization "easy"
<!-- .element: class="fragment" data-fragment-index="4" -->

Note:

1. All configuration should be available to be set in the environment - a number of the configuration files required customization to use environment variables hence we maintain a set of patches to correct this

2. SPARC must be run from the root context of a domain - much of the coffee script is context aware and thus prevents alternative deployment approaches.

3. The delayed_jobs required its own container, because of various factors in the app it stopped working for us as a Cron - required by upgrade to 3.6 - delays in emails and calculations

4. Because Ruby/Rails we are successfully able to customize our images to run in our environment.

Packaging in a container helps insulate our changes and requirements from the original SPARC software allow us to adjust SPARC to our needs rather than forcing the original SPARC code to adapt to us. It means we don't have to pollute our systems with a bunch of dependencies that we have to manage over time and allows us to use an immutable version of SPARC directly from the source.

---

## References

* https://en.wikipedia.org/wiki/Docker_(software)
* https://www.docker.com/resources/what-container
* https://stackoverflow.com/questions/16047306/how-is-docker-different-from-a-virtual-machine
* https://docs.docker.com/engine/faq/#what-does-docker-technology-add-to-just-plain-lxc
* Title background credit: [doomlordvekk](https://www.flickr.com/photos/doomlordvekk/), [Plasma](https://www.flickr.com/photos/doomlordvekk/2719626258/in/photolist-59jN8U-awvt-2jndSq-aJJ7K4-5YKpqJ-6jabwr-2gh9NJ6-4ERsT2-bv56gt-qbPw2m-eyjbP9-bAfkTW-9mx86a-7cLCxj-oxNJ1T-2kqvg9-vcAvs-6oNTSz-4vdMWj-58J2TF-7rQj8B-5mL3nm-4J73nQ-a4bfoi-a4bfoV-a4e63C-8mCsku-aMiweD-5YrUNg-yGM3p-4jZFcU-6tAbXy-2y1V84-pLGpfN-6oaX1g-gsyChd-qzfC5z-bV5Bmv-9mAksE-4jZFAJ-xnuSnm-dEcfrq-bpZeh-64KEru-28PCYL-5Dpy7Y-56jjC-4vdMTN-4EjCTj-pKaF), used under the [Creative Commons license](https://creativecommons.org/licenses/by-nc-nd/2.0/legalcode)


---

# Thank you!

benton@ohsu.edu
