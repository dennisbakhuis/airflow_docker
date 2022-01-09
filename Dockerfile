FROM python:3.9.9-slim-buster

RUN apt-get update && apt-get upgrade

RUN useradd -ms /bin/bash home_server
USER home_server
WORKDIR /home/home_server

RUN python -m pip install --upgrade pip
ENV VIRTUAL_ENV=/home/home_server/venv
RUN python -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY requirements.txt requirements.txt
RUN python -m pip install -r requirements.txt

ENV AIRFLOW_HOME=/home/home_server/airflow
RUN mkdir -pv $AIRFLOW_HOME
ENV AIRFLOW__CORE__EXECUTOR=LocalExecutor

ENV HOMESERVER_AIRFLOW_USER=admin
ENV HOMESERVER_AIRFLOW_PASSWORD=admin
ENV HOMESERVER_AIRFLOW_FIRSTNAME=Peter
ENV HOMESERVER_AIRFLOW_LASTNAME=Parker
ENV HOMESERVER_AIRFLOW_EMAIL=example@domain.org
ENV HOMESERVER_AIRFLOW_PORT=8080

COPY launcher launcher

ENTRYPOINT ["/bin/bash"]

CMD [ "/home/home_server/launcher" ]
