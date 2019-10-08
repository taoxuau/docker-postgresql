# PostgreSQL with High Availability in Docker

## Quick start
```bash
# Hot Standby - Write-Ahead Log Shipping with streaming replication
# start one master server and two standby servers
docker-compose up -d --scale db.standby=2
# check logs
docker-compose logs -f db.standby
```

## Testing
```bash
# create a table and insert a record to db.master
docker-compose exec -T db.master psql --host localhost --username devops --dbname postgres <<-EOSQL
  CREATE TABLE IF NOT EXISTS account(
    user_id serial PRIMARY KEY,
    username VARCHAR (50) UNIQUE NOT NULL,
    password VARCHAR (50) NOT NULL,
    email VARCHAR (355) UNIQUE NOT NULL,
    created_on TIMESTAMP NOT NULL,
    last_login TIMESTAMP
  );
  DELETE FROM account;
  INSERT INTO account (username, password, email, created_on)
  VALUES ('admin', 'admin', 'admin@domain.com', NOW());
  SELECT * FROM account;
EOSQL

# NOTE: change the parameter --index (e.g. --index=1) to check other standby servers
# the data has been replicated to db.standby
docker-compose exec -T --index=2 db.standby psql --host localhost --username devops --dbname postgres <<-EOSQL
  SELECT * FROM account;
EOSQL

# cannot write/delete data on db.standby
docker-compose exec -T --index=2 db.standby psql --host localhost --username devops --dbname postgres <<-EOSQL
  DELETE FROM account;
EOSQL
# ERROR:  cannot execute DELETE in a read-only transaction
```

## Environment
```bash
$ cat /etc/redhat-release
CentOS Linux release 7.7.1908 (Core)

$ docker --version
Docker version 1.13.1, build 7f2769b/1.13.1

$ docker-compose --version
docker-compose version 1.24.1, build 4667896b

$ docker images --format "{{.Repository}}:{{.Tag}}"
docker.io/postgres:11.5-alpine
```

## Reference
- https://medium.com/@2hamed/replicating-postgres-inside-docker-the-how-to-3244dc2305be
- https://www.postgresql.org/docs/11/high-availability.html
