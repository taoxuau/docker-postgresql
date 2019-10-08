# Replicating Postgres inside Docker
# https://medium.com/@2hamed/replicating-postgres-inside-docker-the-how-to-3244dc2305be
#
# official base image
FROM postgres:11.5-alpine

# Use mode={master|standby}
ARG mode

# Warning: scripts in /docker-entrypoint-initdb.d are only run if you start the container
#          with a data directory that is empty
# See https://docs.docker.com/samples/library/postgres/#initialization-scripts
COPY ./pg.$mode.setup.sh /docker-entrypoint-initdb.d/pg.$mode.setup.sh

# Set PGDATA immediate after shebang
RUN set -ex \
  && sed -i "2s/^/PGDATA=\/var\/lib\/postgresql\/data\/$mode\/"'$HOSTNAME'"\n\n/" /usr/local/bin/docker-entrypoint.sh
