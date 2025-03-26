#!/bin/bash

if command -v docker-compose >/dev/null 2>&1; then
  exec docker-compose "$@"
else
  exec docker compose "$@"
fi
