Dockerfile for MythWeb.

Modified build from sparklyballs/docker-containers

You need to edit src/mythweb.conf and set your host/db options

Build with:


docker build -t mythweb .

Run with:

docker run -ti -p 50050:50050 mythweb


TODO:

1. Make mount points for mythweb.conf
2. Make build smaller
3. Make variables passed in with environment vars on build
