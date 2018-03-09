FROM ubuntu:16.04

ENV PYTHON3_VERSION=3.6
ENV PPA=ppa:lincoln-loop/uwsgi
ENV SETUPTOOLS_ARCHIVE=https://pypi.python.org/packages/e0/02/2b14188e06ddf61e5b462e216b15d893e8472fca28b1b0c5d9272ad7e87c/setuptools-38.5.2.zip

ENV BUILD_PKGS software-properties-common build-essential devscripts debhelper dh-python curl unzip
ENV UWSGI_PKGS libpcre3-dev libssl-dev libffi-dev libjansson-dev
ENV PYTHON_PKGS python${PYTHON3_VERSION} python${PYTHON3_VERSION}-dev python python-dev python-setuptools

RUN set -ex && apt-get update && apt-get install -yq ${BUILD_PKGS} ${UWSGI_PKGS} && \
    apt-get update && add-apt-repository ppa:deadsnakes/ppa && apt-get update && \
    apt-get install -yq ${PYTHON_PKGS}

ENV DOGSTATSD_VERSION=1a04f784491ab0270b4e94feb94686b65d8d2db1 UWSGI_VERSION=2.0.17 UWSGI_EMBED_PLUGINS=dogstatsd

RUN curl -LsOS https://github.com/DataDog/uwsgi-dogstatsd/archive/${DOGSTATSD_VERSION}.tar.gz && \
    curl -LsOS https://github.com/unbit/uwsgi/archive/${UWSGI_VERSION}.tar.gz && \
    curl -sS -o setuptools.zip ${SETUPTOOLS_ARCHIVE} && \
    tar xvzf ${UWSGI_VERSION}.tar.gz && tar xvzf ${DOGSTATSD_VERSION}.tar.gz && unzip setuptools.zip && \
    mv /uwsgi-${UWSGI_VERSION} /uwsgi && \
    mv uwsgi-dogstatsd-${DOGSTATSD_VERSION} /uwsgi/plugins/dogstatsd && \
    mv setuptools-* /uwsgi/setuptools_src


WORKDIR /uwsgi
ADD debian /uwsgi/debian

RUN set -ex && dpkg-buildpackage -us -uc && \
    dpkg -I /python2.7-uwsgi*.deb && dpkg-deb -c /python2.7-uwsgi*.deb && dpkg -i /python2.7-uwsgi*.deb && \
    echo "\n\n" && \
    dpkg -I /python${PYTHON3_VERSION}-uwsgi*.deb && dpkg-deb -c /python${PYTHON3_VERSION}-uwsgi*.deb && dpkg -i /python${PYTHON3_VERSION}-uwsgi*.deb
CMD /bin/bash -c "debuild --no-tgz-check -S -sa && dput ${PPA} /python-uwsgi_*_source.changes"
