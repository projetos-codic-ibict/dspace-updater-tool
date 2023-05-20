# (versão beta) Migrador de versões antigas do DSpace para versão 7

Autor: Márcio Gurgel (marcio.rga@gmail.com)

## Procedimento

- Instale os comandos "docker" e "docker compose" no seu servidor;
- Copie o diretório de instalação do DSpace antigo para o servidor onde o DSpace 7 irá rodar. Os diretórios obrigatórios são: config, assetstore e solr.
- Preencha o arquivo `variaveis-para-atualizacao.properties` .
- Adicione configurações adicionais no arquivo `dspace.cfg`, como informações para envio de e-mail, etc.
- Rode o script `backend_migra-para-dspace7.sh`
  - Em caso de problemas nesta etapa, refaça o procedimento pelo script `backend_refaz-migracao.sh`
- Rode o script `frontend_migra-para-dspace7.sh`
    - Em caso de problemas nesta etapa, refaça o procedimento pelo script `frontend_refaz-migracao.sh`

- Aguarde o processamento, o tempo de processamento irá depender do desempenho do servidor;
- Acesse a interface do DSpace utilizando os endereços inseridos no arquivo `variaveis-para-atualizacao.properties`.


## Problemas comuns

### Erro 500 na tela
- Verifique se está acessando o DSpace pelo endereço cadastrado no arquivo `variaveis-para-atualizacao.properties`
- Verifique se o endereço retornado pelo comando `docker exec -it dspace7 cat /dspace/config/local.cfg | grep  dspace.ui.url` confere com o cadastrado no arquivo `variaveis-para-atualizacao.properties`. Caso negativo, refaça a migração com os valores corretos. Isso pode acontecer caso você tenha feito o "backend" apontando para um endereço e o "frontend" apontando para outro endereço.


### Tela branca
- Verifique se os endereços IP/Porta fornecidos no arquivo `variaveis-para-atualizacao.properties` estão acessíveis.