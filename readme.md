# DSpace upgrade tool (versions 4, 5, 6) to DSpace 7

# Notice:
- This is a Beta Version
- Commercial use is not allowed

Autor: Márcio Gurgel (marcio.rga@gmail.com)

## Procedimento

- Instale os comandos "docker" e "docker compose" no seu servidor;
- Gere um dump do banco de dados (PostgreSQL) com o comando `pg_dump`. O nome do arquivo deve ser `dump.sql` e deve ser colocado no diretório `dump-postgres`;
  - Comando de exemplo para geração do dump:
    `pg_dump --dbname=postgresql://dspace:dspace@192.169.5.126:5005/dspace > dump.sql`
- Copie o diretório de instalação do DSpace antigo para o servidor onde o DSpace 7 irá rodar. Os diretórios obrigatórios são: config, assetstore e solr.
- Preencha o arquivo `variaveis-para-atualizacao.properties` .
- Adicione configurações adicionais no arquivo `dspace.cfg`, como informações para envio de e-mail, etc.
- Rode o script `migra-para-dspace7.sh`
  - Caso ocorra algum problema com o preenchimento das variáveis, efetue a correção e rode o script novamente.

- Aguarde o processamento, o tempo de processamento irá depender do desempenho do servidor;
- Acesse a interface do DSpace utilizando os endereços inseridos no arquivo `variaveis-para-atualizacao.properties`.


## Informações adicionais sobre a instalação

- O diretório de instalação do DSpace será [DSPACE_UPGRADE_TOOL]/dspace-install-dir, considere esta pasta para backup;
- O banco de dados pode receber backup pelo comando: ```docker exec -t dspace7db pg_dumpall -c -U postgres > [DEST_DIR]/dump_`date +%d-%m-%Y"_"%H_%M_%S`.sql```

## Problemas comuns

### Erro 500 na tela
- Verifique se está acessando o DSpace pelo endereço cadastrado no arquivo `variaveis-para-atualizacao.properties`
- Verifique se o endereço retornado pelo comando `docker exec -it dspace7 cat /dspace/config/local.cfg | grep  dspace.ui.url` confere com o cadastrado no arquivo `variaveis-para-atualizacao.properties`. Caso negativo, refaça a migração com os valores corretos. Isso pode acontecer caso você tenha feito o "backend" apontando para um endereço e o "frontend" apontando para outro endereço.


### Tela branca
- Verifique se os endereços IP/Porta fornecidos no arquivo `variaveis-para-atualizacao.properties` estão acessíveis.