#!/bin/bash
# Variável que define as opções de codificação
LAMEOPTS="-vcodec copy -acodec copy"

# Início do script, momento válvula se escape
clear
echo "Este script converte todos os arquivos de vídeo no formato"
echo "flv (.flv) na pasta atual para o formato AVI(avi) usando o"
echo "ffmpeg com a mesma qualidade. Este processo talvez demore"
echo "Para abortar, pressione <Control>+C pra finalizar..."
# sleep 30s
echo
echo "Iniciando o processo de conversão dos arquivos..."

# Corpo do script
for FILE in *.flv; do
	OUTNAME=`basename "$FILE" .flv`.avi
	echo "Convertendo o arquivo $FILE para o formato .avi..."
	ffmpeg -i "$FILE" $LAMEOPTS "$OUTNAME"
	echo "Arquivo $FILE convertido com sucesso!"
	echo
done
echo "Todos os arquivos foram convertidos com sucesso!"
# Fim do script
