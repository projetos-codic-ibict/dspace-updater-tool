source ./variaveis-para-atualizacao.properties
cd $DIRETORIO_DOWNLOAD_FRONTEND
wget https://github.com/DSpace/DSpace/archive/refs/tags/dspace-7.5.zip
unzip dspace-7.5.zip
rm dspace-7.5.zip



cd $DIRETORIO_DOWNLOAD_BACKEND
wget https://github.com/DSpace/dspace-angular/archive/refs/tags/dspace-7.5.zip
unzip dspace-7.5.zip
rm dspace-7.5.zip


