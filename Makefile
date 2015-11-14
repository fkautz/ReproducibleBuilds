default: build

build:
	docker build -t repro .

run: build
	docker run --privileged -v `pwd`/results:/code/results -v squid:/var/spool/squid repro make PACKAGE="${PACKAGE}" build-rpm copy-results compare

term: build
	docker run --privileged -i -t -v cache:/code/cache -v `pwd`/results:/code/results -v squid:/var/spool/squid repro /bin/bash

clean:
	rm -rf results/*

git-example:
	make PACKAGE="git-2.5.0-2.fc23" run

openssh-example:
	make PACKAGE="openssh-7.1p1-5.fc23.x86_64.rpm" run

cpio-example:
	make PACKAGE="cpio-2.11-36.fc23" run
