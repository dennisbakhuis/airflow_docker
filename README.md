Airflow docker version
----------------------
Simple container for running a containerized version of Apache Airflow
on your home server. I use this for simple in house ETL jobs but it
might be useful for you too.

Requirements
------------
This container is best used with a external database backend. I use
PostgreSQL in a separate container. See below on how to spin up
a PostgreSQL container. The sql-alchemy connection string needs to be
provided to `AIRFLOW__CORE__SQL_ALCHEMY_CONN` runtime environment
variable. If this variable is not set, it will use a sqlite DB which
works but is not recommended, even for small workloads.

Example:
AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql+psycopg2://username:password@server_url:port/db_name

Python dependencies for DAGs
----------------------------
These can be added to requirements.txt, but then a new container needs
to be build. As an easier method, packages can be added to the
`HOMESERVER_ADDITIONAL_PIP_PACKAGES` variable during runtime. These
will be installed when the container starts.

Run using docker-compose
------------------------
Add the following to your docker-compose.yml file:
```yaml
services:
  airflow:
    image: dennisbakhuis/airflow_docker:latest
    container_name: airflow
    restart: unless-stopped
    networks:
      - t2_proxy
    ports:
      - "8080:8080"
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - $DOCKERDIR/airflow:/home/home_server/airflow
      - $DOCKERDIR/airflow_dags:/home/home_server/airflow/dags
    user: "$PUID:$PGID"
    environment:
      - HOMESERVER_ADDITIONAL_PIP_PACKAGES=pandas==1.3.5 webdav4==0.9.3
      - AIRFLOW__CORE__SQL_ALCHEMY_CONN=$POSTGRESQL_CONNECTION_STRING
      - AIRFLOW__CORE__DAGS_FOLDER=/home/home_server/airflow/dags
      - BAKHUIS_DATALAKE=$BAKHUIS_DATALAKE
      - BAKHUIS_INFLUXDB_TOKEN=$BAKHUIS_INFLUXDB_TOKEN
```


Build container
---------------
```bash
DOCKER_BUILDKIT=1 docker build -t airflow-homeserver:latest .
```

Run container
-------------
```bash
docker run \
  -it \
  --rm \
  -p 8080:8080 \
  -v $(pwd)/airflow_home/:/home/home_server/airflow \
  -e HOMESERVER_ADDITIONAL_PIP_PACKAGES="pandas==1.3.5 webdav4==0.9.3" \
  -e AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql+psycopg2://username:password@server_url:port/db_name \
  airflow-homeserver:latest
```

Push to docker hub
------------------
You obviously need a Docker hub account.

```bash
docker login
docker tag airflow-homeserver:lastest dennisbakhuis/airflow_docker:latest
docker push dennisbakhuis/airflow_docker:lastest
```
