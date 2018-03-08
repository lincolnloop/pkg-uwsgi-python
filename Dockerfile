FROM ubuntu:16.04

ENV PYTHON3_VERSION=3.6

RUN set -ex && apt-get update && apt-get install -yq software-properties-common build-essential devscripts debhelper dh-python libpcre3-dev libssl-dev libffi-dev libjansson-dev unzip curl && \
    apt-get update && add-apt-repository ppa:deadsnakes/ppa && apt-get update

RUN apt-get install -yq python python-dev python-setuptools python${PYTHON3_VERSION} python${PYTHON3_VERSION}-dev && \
    curl -sOS https://bootstrap.pypa.io/get-pip.py && python${PYTHON3_VERSION} get-pip.py

ENV DOGSTATSD_VERSION=1a04f784491ab0270b4e94feb94686b65d8d2db1 UWSGI_VERSION=2.0.17 UWSGI_EMBED_PLUGINS=dogstatsd

RUN curl -LsOS https://github.com/DataDog/uwsgi-dogstatsd/archive/${DOGSTATSD_VERSION}.tar.gz && \
    curl -LsOS https://github.com/unbit/uwsgi/archive/${UWSGI_VERSION}.tar.gz && \
tar xvzf ${UWSGI_VERSION}.tar.gz && tar xvzf ${DOGSTATSD_VERSION}.tar.gz && mv uwsgi-dogstatsd-${DOGSTATSD_VERSION} uwsgi-${UWSGI_VERSION}/plugins/dogstatsd && mv /uwsgi-${UWSGI_VERSION} /uwsgi

WORKDIR /uwsgi
ADD debian /uwsgi/debian

RUN set -ex && dpkg-buildpackage -us -uc && \
    dpkg -I /python2.7-uwsgi*.deb && dpkg-deb -c /python2.7-uwsgi*.deb && \
    echo "\n\n" && \
    dpkg -I /python${PYTHON3_VERSION}-uwsgi*.deb && dpkg-deb -c /python${PYTHON3_VERSION}-uwsgi*.deb
CMD /bin/bash -c "debuild --no-tgz-check -S -sa && dput ppa:lincolnloop/uwsgi /python-uwsgi_*_source.changes"
