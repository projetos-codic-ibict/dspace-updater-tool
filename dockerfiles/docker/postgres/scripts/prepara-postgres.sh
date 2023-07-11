#!/bin/bash

set -e

function cria_usuario_e_bd() {
    echo "Criando usuário DSpace"
    psql --username=postgres -c "CREATE USER dspace WITH PASSWORD 'cDVf9UnCskeirG4K';"
    psql --username=postgres -c "CREATE DATABASE dspace WITH OWNER dspace;"
    psql --username=postgres -c "GRANT ALL PRIVILEGES ON DATABASE dspace TO dspace;"
}

function instala_pg_crypto() {
    echo "Criando pgCrypto"
    psql --username=postgres dspace -c "CREATE EXTENSION pgcrypto;"
}

cria_usuario_e_bd
instala_pg_crypto

if [[ -f /opt/dump.sql ]]; then
  echo "Identificado arquivo de DUMP efetuando a restauração"
  psql -d dspace -U dspace -f /opt/dump.sql
fi