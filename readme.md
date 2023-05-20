# Migrador de versões antigas do DSpace para versão 7

Autor: Márcio Gurgel (marcio.rga@gmail.com)


### Problemas comuns

#### Erro 500 na tela
- Verifique se está acessando o DSpace pelo endereço cadastrado no arquivo `variaveis-para-atualizacao.properties`
- Verifique se o endereço retornado pelo comando `docker exec -it dspace7 cat /dspace/config/local.cfg | grep  dspace.ui.url` confere com o cadastrado no arquivo `variaveis-para-atualizacao.properties`. Caso negativo, refaça a migração com os valores corretos. Isso pode acontecer caso você tenha feito o "backend" apontando para um endereço e o "frontend" apontando para outro endereço.


#### Tela branca
- Verifique se os endereços IP/Porta fornecidos no arquivo `variaveis-para-atualizacao.properties` estão acessíveis.