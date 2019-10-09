#!/bin/bash
set -ex

# pg_hba.conf
echo "host replication all 0.0.0.0/0 md5" >>"$PGDATA/pg_hba.conf"

# postgresql.conf
cat >>${PGDATA}/postgresql.conf <<EOF
wal_level = replica
archive_mode = on
archive_command = 'cd .'
max_wal_senders = 8
wal_keep_segments = 8
hot_standby = on
EOF

# create replication user
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE USER $PG_MASTER_REP_USER REPLICATION LOGIN CONNECTION LIMIT 100 ENCRYPTED PASSWORD '$PG_MASTER_REP_PASS';
EOSQL
