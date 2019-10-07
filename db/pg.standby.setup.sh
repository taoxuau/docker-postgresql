#!/bin/bash
set -ex

# .pgpass
echo "*:*:*:$PG_MASTER_REP_USER:$PG_MASTER_REP_PASS" >~/.pgpass
chmod 0600 ~/.pgpass

# make sure standby's data directory is empty
#   1. posgresql server is already started by docker-entrypoint.sh
#   2. stop the server and clear $PGDATA directory
pg_ctl -D "$PGDATA" -m fast -w stop
rm -r "$PGDATA"/*

# waiting for postgres master
echo -n "Waiting for postgres master starting..."
while ! nc -z $PG_MASTER_HOST $PG_MASTER_PORT; do
  sleep 0.1
done
echo "done"

# waiting for taking a base backup of the postgres master
# 1. using password from ~/.pgpass
# 2. $PGDATA has to be empty before running pg_basebackup
# See https://www.postgresql.org/docs/current/app-pgbasebackup.html
while ! pg_basebackup -h ${PG_MASTER_HOST} -D ${PGDATA} -U ${PG_MASTER_REP_USER} --verbose --progress --no-password; do
  sleep 0.1
done

# postgresql.conf
sed -i 's/wal_level = hot_standby/wal_level = replica/g' ${PGDATA}/postgresql.conf

# recovery.conf
cat >${PGDATA}/recovery.conf <<EOF
standby_mode = 'on'
primary_conninfo = 'host=$PG_MASTER_HOST port=$PG_MASTER_PORT user=$PG_MASTER_REP_USER password=$PG_MASTER_REP_PASS'
trigger_file = '/tmp/touch_me_to_promote_me_to_postgres_master'
EOF

# https://github.com/docker-library/postgres/blob/master/11/docker-entrypoint.sh
# internal start of server, will be stopped by docker-entrypoint.sh
# does not listen on external TCP/IP and waits until start finishes
pg_ctl -D "$PGDATA" -o "-c listen_addresses=''" -w start
