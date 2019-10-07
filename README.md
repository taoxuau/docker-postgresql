# PostgreSQL with High Availability in Docker

## Testing
```bash
# WIP
docker-compose up -d

docker-compose exec db.master bash

psql --host localhost --username devops --dbname postgres

CREATE TABLE account(
   user_id serial PRIMARY KEY,
   username VARCHAR (50) UNIQUE NOT NULL,
   password VARCHAR (50) NOT NULL,
   email VARCHAR (355) UNIQUE NOT NULL,
   created_on TIMESTAMP NOT NULL,
   last_login TIMESTAMP
);

INSERT INTO account (username, password, email, created_on)
VALUES ('admin', 'admin', 'admin@domain.com', NOW());

SELECT * FROM account;
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
