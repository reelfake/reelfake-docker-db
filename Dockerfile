FROM postgres:17.6

RUN apt update
RUN apt install curl jq -y

ENV POSTGRES_DATABASE=reelfake_db

COPY scripts/01_download_csv_files.sh /docker-entrypoint-initdb.d/
COPY scripts/02_setup_db.sql /docker-entrypoint-initdb.d/
COPY scripts/03_remove_csv_files.sh /docker-entrypoint-initdb.d/

RUN chmod +x /docker-entrypoint-initdb.d/01_download_csv_files.sh
RUN chmod +x /docker-entrypoint-initdb.d/03_remove_csv_files.sh 

RUN mkdir /docker-entrypoint-initdb.d/data
RUN chmod a+r /docker-entrypoint-initdb.d/*
RUN chmod o+w /docker-entrypoint-initdb.d/data

EXPOSE 5432