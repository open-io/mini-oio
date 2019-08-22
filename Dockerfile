FROM ubuntu:bionic

LABEL io.openshift.s2i.scripts-url="image:///builder"

COPY deps/ /tmp
RUN apt-get update && \
    apt-get install -y git curl software-properties-common && \
    curl http://mirror.openio.io/pub/repo/openio/APT-GPG-KEY-OPENIO-0 | apt-key add - && \
    apt-add-repository "deb http://mirror.openio.io/pub/repo/openio/sds/19.04/ubuntu/ bionic/" && \
    apt-get update && \
    apt-get install -y $(awk '{print $2}' /tmp/deps-ubuntu-bionic.txt) && \
    apt-get clean

WORKDIR /app

RUN groupadd -g 1000 openio && \
    useradd -u 1000 -g openio -G 0 -d /app openio && \
    chown -R 1000:1000 /app

USER 1000

RUN virtualenv /app/venv

RUN /app/venv/bin/pip install -U pip wheel setuptools && \
    /app/venv/bin/pip install -r /tmp/requirements.txt

RUN go get gopkg.in/ini.v1 && \
    go get golang.org/x/sys/unix

COPY scripts/ /builder

COPY --chown=1000:0 oio/ /app/.oio

CMD ["/builder/usage"]
