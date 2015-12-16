FROM fedora:23

ENV container docker

RUN dnf update -y && dnf clean all
RUN dnf install python-celery python-requests koji python-urlgrabber python-setuptools python-billiard createrepo mock -y && dnf clean all
RUN dnf install dnf-plugins-core -y && dnf clean all
RUN dnf install redis python-redis -y && dnf clean all
RUN dnf install squid -y && dnf clean all
RUN echo "proxy=http://localhost:3128" >> /etc/dnf/dnf.conf
RUN echo "cache_dir ufs /var/spool/squid 2048 16 256" >> /etc/squid/squid.conf
RUN echo "cache_effective_user squid" >> /etc/squid/squid.conf

COPY . /code
WORKDIR /code
RUN cp Makefile.container Makefile
CMD make build-rpm

