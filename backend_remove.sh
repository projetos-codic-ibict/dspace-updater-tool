#!/bin/bash

printf '
--------------------------------------
\U0001F170
--------------------------------------
\e[1mPT_BR\e[0m: Backend: Removendo arquivos e container de execuções antigas (caso eles existam).
Sua senha root será solicitada.

\e[1mEN\e[0m: Backend Deleting old files and containers from previous executions (in case they exists).
Your root password will be requested.
'

{
  echo "" > execution.log
  sudo rm -rf ./tmp/*
  sudo rm -rf ./dspace-install-dir/*

  sudo rm -rf ./DSpace-dspace-8.1 || true
  sudo rm -rf ./source/DSpace-dspace-8.1 || true
  rm dspace-8.1.zip || true >/dev/null 2>&1

  docker rm -f dspace7 || true >/dev/null 2>&1
  docker rmi -f dspace-dspace-76-dspace7 || true >/dev/null 2>&1

  docker rm -f dspace7db || true >/dev/null 2>&1
  docker rm -f dspace7solr || true >/dev/null 2>&1
  docker rmi -f ibict/postgresdspace7 || true >/dev/null 2>&1

  docker volume rm dspace-dspace-75_solr_data || true >/dev/null 2>&1
} >> execution.log 2>&1

