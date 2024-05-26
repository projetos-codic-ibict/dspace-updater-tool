#!/bin/bash

if ! command -v docker &> /dev/null; then
printf '
----------------ERROR-----------------
\e[1mPT_BR\e[0m: O programa "docker" não está instalado. Instale em: https://docs.docker.com/engine/install/
\e[1mEN\e[0m: The "docker" program is not installed. Install it: https://docs.docker.com/engine/install/
--------------------------------------
'
    exit 1
fi

# Verificar se o Docker está em execução
if ! docker info &> /dev/null; then
printf '
----------------ERROR-----------------
\e[1mPT_BR\e[0m: O programa "docker" não está em execução.
\e[1mEN\e[0m: The "docker" program is not running.
--------------------------------------
'
    exit 1
fi

if [ "$EUID" -ne 0 ]; then
printf '
----------------ERROR-----------------
\e[1mPT_BR\e[0m: Este programa precisa ser rodado como root.
\e[1mEN\e[0m: It is necessary to run this program as root.
--------------------------------------
'
    exit 1
fi

# RAM in this machine
total_ram=$(free -b | grep "Mem:" | awk '{print $2}')

# Convert to GB
total_ram_gb=$(echo "scale=2; $total_ram / (1024 * 1024 * 1024)" | bc)

if (( $(echo "$total_ram_gb < 8" | bc -l) )); then
printf '
----------------ERROR-----------------
\e[1mPT_BR\e[0m: É necessário ao menos 8GB de RAM para rodar este programa.
\e[1mEN\e[0m: It is necessary to have at least 8GB of ram to run this program.
--------------------------------------
'
    exit 1
fi


source ./backend_remove.sh
source ./backend_build.sh
source ./frontend_rebuild.sh
