FROM postgres:12
LABEL maintainer="Márcio Gurgel <marcio.rga@gmail.com>"

EXPOSE 5432
COPY *.sql /opt/

RUN echo "Iniciando a construção"
COPY ./scripts/prepara-postgres.sh /docker-entrypoint-initdb.d/
RUN chmod -R 777 /opt
RUN chmod 775 /docker-entrypoint-initdb.d/prepara-postgres.sh
