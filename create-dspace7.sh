#!/bin/bash

source ./backend_remove.sh
source ./backend_build.sh default-ibict
source ./frontend_rebuild.sh

printf '
--------------------------------------
\U00023F3
--------------------------------------
\e[1mPT_BR\e[0m: Crie o seu primeiro usuário administrador do DSpace
\e[1mEN\e[0m: Create the fist admin user
'
docker exec -it dspace7 /dspace/bin/dspace create-administrator