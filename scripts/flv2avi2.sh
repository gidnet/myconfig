#!/bin/bash
# Vari�vel que define as op��es de codifica��o
LAMEOPTS="-oac mp3lame -lameopts cbr:br=96 -ovc lavc -lavcopts vcodec=mpeg4:vbitrate=800"

# In�cio do script, momento v�lvula se escape
clear
echo "Este script converte todos os arquivos de v�deo no formato"
echo "flv (.flv) na pasta atual para o formato AVI(avi) usando o"
echo "ffmpeg com a mesma qualidade. Este processo talvez demore"
echo "Para abortar, pressione <Control>+C pra finalizar..."
# sleep 30s
echo
echo "Iniciando o processo de convers�o dos arquivos..."

# Corpo do script
for FILE in *.flv; do
	OUTNAME=`basename "$FILE" .flv`.avi
	echo "Convertendo o arquivo $FILE para o formato .avi..."
	mencoder $LAMEOPTS "$FILE" -o "$OUTNAME"
	echo "Arquivo $FILE convertido com sucesso!"
	echo
done
echo "Todos os arquivos foram convertidos com sucesso!"
# Fim do script
