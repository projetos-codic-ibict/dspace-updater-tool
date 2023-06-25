# DSpace upgrade tool (versions 4, 5, 6) to DSpace 7

# Notice:
- This is a Beta Version
- Commercial use is not allowed

Autor: Márcio Gurgel (marcio.rga@gmail.com)

# PT_BR (english bellow)

# Sobre
Esta ferramenta atualiza qualquer DSpace nas versões 4, 5 ou 6 para a versão 7.5 com pouca necessidade de intervenção humana.

## O que a ferramenta faz?

- Atualiza os formulários de submissão para o novo formato do DSpace 7;
- Importa as estatísticas de uso do Solr da instalação antiga para a instalação nova;
- Atualiza banco de dados para a versão 7;
- Cria e incializa os serviços: banco de dados, dspace server, dspace angular e PostgreSQL;

## Procedimento para migrar para o Dspace 7

- Instale os comandos "docker" e "docker compose" no seu servidor;
- Gere um dump do banco de dados (PostgreSQL) com o comando `pg_dump`. O nome do arquivo deve ser `dump.sql` e deve ser colocado no diretório `dump-postgres`;
  - Comando de exemplo para geração do dump:
    `pg_dump --dbname=postgresql://dspace:dspace@192.169.5.126:5005/dspace > dump.sql`
- Copie o diretório de instalação do DSpace antigo para o servidor onde o DSpace 7 irá rodar. Os diretórios obrigatórios são: config, assetstore, webapps e solr.
- Preencha o arquivo `[DSPACE_UPGRADE_TOOL]/upgrade-variables.properties` .
  - Caso você já possua um repositório GIT com seu DSpace 7.5, informe o endereço neste arquivo, a ferramenta irá fazer o clone ao invés de fazer download do zip do repositório do DSpace original.  
- Adicione configurações adicionais no arquivo `dspace.cfg`, como informações para envio de e-mail, etc.
- Rode o script `upgrade-to-dspace7.sh`
  - Caso ocorra algum problema com o preenchimento das variáveis, efetue a correção e rode o script novamente.

- Aguarde o processamento, o tempo de processamento irá depender do desempenho do servidor;
- Acesse a interface do DSpace utilizando os endereços inseridos no arquivo `[DSPACE_UPGRADE_TOOL]/upgrade-variables.properties`.

## Procedimento para aplicar mudanças no DSpace 7


### Front-end (angular)
- Caso você tenha especificado um repositório git para sua interface angular, no arquivo `upgrade-variables.properties` esta ferramenta fará o `pull` do novo código e recompilar o código-fonte localizado em:  `[DSPACE_UPGRADE_TOOL]/source/dspace-angular-dspace-7.5`;
- Caso você não tenha informado um repositório Git, esta ferramenta irá apenar recompilar o código presente em: `[DSPACE_UPGRADE_TOOL]/source/dspace-angular-dspace-7.5`;
- Para recompilar a interface, execute:  `./restart-frontend.sh`

### Backend
- Para aplicar mudanças feitas no diretório de instalação, (`[DSPACE_UPGRADE_TOOL]/dspace-install-dir`) execute `./restart-backend.sh`


### Todos logs serão escritos em: `[DSPACE_UPGRADE_TOOL]/execution.log`

## Informações adicionais sobre a instalação

- O diretório de instalação do DSpace será [DSPACE_UPGRADE_TOOL]/dspace-install-dir, considere esta pasta para backup;
- O banco de dados pode receber backup pelo comando: ```docker exec -t dspace7db pg_dump -c -U postgres dspace > [DEST_DIR]/dump_`date +%d-%m-%Y"_"%H_%M_%S`.sql```

## Problemas comuns

### Erro 500 na tela
- Verifique se está acessando o DSpace pelo endereço cadastrado no arquivo `[DSPACE_UPGRADE_TOOL]/upgrade-variables.properties`
- Verifique se o endereço retornado pelo comando `docker exec -it dspace7 cat /dspace/config/local.cfg | grep  dspace.ui.url` confere com o cadastrado no arquivo `[DSPACE_UPGRADE_TOOL]/upgrade-variables.properties`. Caso negativo, refaça a migração com os valores corretos. Isso pode acontecer caso você tenha feito o "backend" apontando para um endereço e o "frontend" apontando para outro endereço.


### Tela branca
- Verifique se os endereços IP/Porta fornecidos no arquivo `[DSPACE_UPGRADE_TOOL]/upgrade-variables.properties` estão acessíveis.

- 
---

# EN

# About
This tool upgrades any DSpace 4, 5 or 6 to the latest DSpace 7.5, without the need of human intervention.

## Key points

- Upgrades the old submisison forms (xml) to the new DSpace 7 format;
- Imports the Solr statistics from the old DSpace to DSpace 7;
- Upgrades the DSpace's database strcuture to the latest version;
- In other words, criates and initializes the services: database, dspace server, dspace angular and postgresql;
- This tool does not require your server to have other programs, such as: java, ant, maven, postgres, tomcat, solr, etc. The only required program is "doocker" 

## Procedure to migration

- Have a linux S.O.;
- Download this repo;
- Install the commands `docker` and `docker compose` in the server which will receive the new DSpace 7. We highly recomend to use a new server for DSpace 7;
- Make sure you have at least 3x more space in disk than the space used by the old DSpace;
- Generate a dump from the old DSpace database, using the command `pg_dump`. The generated dump, must have the name `dump.sql` and must be pasted in the directory `dump-postgres`;
  - Example of command:
    `pg_dump --dbname=postgresql://dspace:dspace@192.169.5.126:5005/dspace > dump.sql`
- Copy the DSPACE_DIR from the old DSpace to any locaiton in the new DSpace;
- Fullfill the variables in `upgrade-variables.properties` ;
  - If you already have an DSpace 7 git repo, you can inform it in this file. Instead of downloading the original zip, this tool will clone your repo; 
- (Optional but important) Add extra configuration to the file `[DSPACE_UPGRADE_TOOL]/local.cfg`, as email credentians, and so on;
- Run the script this way: `./upgrade-to-dspace7.sh`
  - If there's any problem during the installation (eg: forgot to fullfill any variable) you can run this script again;

## Procedure to apply changes on DSpace 7

### Front-end (angular)
- If you've set a git repo for your angular interface, this tool will `pull` the new code and re-compile the source in `[DSPACE_UPGRADE_TOOL]/source/dspace-angular-dspace-7.5`;
- If you haven't set a git repo for your angular interface this tool will just recompile the source in  `[DSPACE_UPGRADE_TOOL]/source/dspace-angular-dspace-7.5`;
- Tô recompile your angular interface, just run  `./restart-frontend.sh`

### Backend
- To apply changes made in the "DSpace dir" (`[DSPACE_UPGRADE_TOOL]/dspace-install-dir`) run `./restart-backend.sh`


All logs will by written in: `[DSPACE_UPGRADE_TOOL]/execution.log`


## Additional informations about the new DSpace instalation

- The new "DSpace DIR" will be: `[DSPACE_UPGRADE_TOOL]/dspace-install-dir`, consider it for backup;
- Backup the database using the following command (fullfill DEST_DIR):  ```docker exec -t dspace7db pg_dump -c -U postgres dspace > [DEST_DIR]/dump_`date +%d-%m-%Y"_"%H_%M_%S`.sql```

## Commum issues

### Error 500 in angular interface
- Verify if you are accessing the interface by the same address you've registered in `[DSPACE_UPGRADE_TOOL]/upgrade-variables.properties`;
- Verify if the address shown by the command `docker exec -it dspace7 cat /dspace/config/local.cfg | grep  dspace.ui.url` is the same registred in `[DSPACE_UPGRADE_TOOL]/upgrade-variables.properties`. If not, correct the variables and run again the script `./upgrade-to-dspace7.sh` again.
### Tela branca
- Verifique se os endereços IP/Porta fornecidos no arquivo `variaveis-para-atualizacao.properties` estão acessíveis.
