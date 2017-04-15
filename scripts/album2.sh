#!/bin/bash
clear
################################################################
# Script gerador de album virtual
# Necessita dos pacotes: imagemagick
#
# autor: Danilo Cesar
# danilo.paula@brturbo.com
################################################################

EXT="jpg"
DIR_DEST=$2            #Diretório destino      "/home/www/album"
DIR_ORI=$1             #Diretório de Origem    "/mnt/hda5/Meu Album/04-04-04 JVR"
ESCALA_IMG=400
ESCALA_THUMB=100
COLUNAS=5

ERRO=0
if [ -z "$1" ];
then
	ERRO=1
fi
if [ -z "$2" ];
then
	ERRO=1
fi

if [ "$ERRO" == 1 ]; then
    echo -e "Forma Correta de usar:"
    echo $(basename $0) "(Origem) (Destino) "
    echo "Origem:/home/usuario/fotos"
    echo "Destino:/home/usuario"
    exit 1
fi

echo "Digite o nome do Album"
read NOME_ALBUM
echo "Digite o Titulo do Album"
read TITULO

######################################################

echo "Acessando pasta de origem" $DIR_ORI
cd "$DIR_ORI"

if [ "$?" != 0 ]; then
    echo "Não foi possível acessar a pasta " $DIR_FOTOS
    exit 1
fi
echo "OK"

echo "Contando Quantidade de fotos a serem utilizadas"
quant=`ls *.${EXT} | wc -l`
if (( $quant == 0 )); then
    echo "Não há fotos no diretório escolhido"
    exit 1
fi
echo $quant "Fotos contadas"

###########################################################
# Criando pastas necessárias
###########################################################
DIR_FOTOS=${DIR_DEST}/fotos/
DIR_FOTOS_S=fotos/
DIR_THUMB=${DIR_DEST}/thumb/
DIR_THUMB_S=thumb/
DIR_HTML=${DIR_DEST}/html/
DIR_HTML_S=html/

echo "Criando pastas" $DIR_FOTOS
mkdir -p $DIR_FOTOS

if [ "$?" != 0 ]; then
    echo "Não foi possível criar o diretório" $DIR_FOTOS
    exit 1
fi
echo -e "Concluido!"

########

echo "Criando pastas" $DIR_THUMB
mkdir -p $DIR_THUMB

if [ "$?" != 0 ]; then
    echo "Não foi possível criar o diretório" $DIR_THUMB
    exit 1
fi
echo -e "Concluido!"

##########

echo "Criando pastas" $DIR_HTML
mkdir -p $DIR_HTML

if [ "$?" != 0 ]; then
    echo "Não foi possível criar o diretório" $DIR_HTML
    exit 1
fi
echo -e "Concluido!"

echo -e "\n\n.........................................\n\n"
echo "Iniciando cópia de arquivos"


###########################################################


#Form indica a formatação(zeros) o nome do arquivo terá
form=$((`echo $quant | wc -c` -1))


i=1
ls *.${EXT} | while read ARQ
do
  nome=`printf {%0${form}d,$i}`
  nome_n=`printf {%0${form}d,$(($i+1))}`
  nome_p=`printf {%0${form}d,$(($i-1))}`

  echo -e "Copiando $ARQ - ($i/$quant)"
  cp $ARQ ${DIR_FOTOS}${nome}.${EXT}

  if [ "$?" != 0 ]; then
      echo "Não foi possível copiar o arquivo " $ARQ
      exit 1
  fi


  echo -e "Redimensionando:  ${DIR_FOTOS}${nome}.${EXT}"
  convert -scale $ESCALA_IMG ${DIR_FOTOS}${nome}.${EXT} ${DIR_FOTOS}${nome}.${EXT}
  if [ "$?" != 0 ]; then
      echo "Não foi possível redimencionar arquivo " ${DIR_FOTOS}${nome}.${EXT}
      exit 1
  fi



  echo -e "Criando Minhatura..."
  convert -thumbnail $ESCALA_THUMB ${DIR_FOTOS}${nome}.${EXT} ${DIR_THUMB}${nome}.${EXT}
  if [ "$?" != 0 ]; then
      echo "Não foi possível converter arquivo " ${DIR_FOTOS}${nome}.${EXT}
      exit 1
  fi

  echo -e "Criando página HTML"

#
# Inicio da página HTML. 
# Variáveis:
# $NEXT -> Link para proxima foto
# $PREV -> Link para foto anterior
# $FOTO_LINK -> Imagem
#
# A Página será criada em cima deste modelo.


FOTO_LINK="<img src=\"../${DIR_FOTOS_S}${nome}.${EXT}\">"
######################################################################
#Linhas Que verificam os Links. Para não criar, por exemplo, link para
#página anterior na página inicial.
######################################################################
if [[ $i -gt 1 ]]; then                                              
    PREV="<a href='${nome_p}.html'>Anterior</a>"
else
    PREV=
fi                                                                   
                                                                     
if [[ $i -lt $quant ]]; then
    NEXT="<a href='${nome_n}.html'>proxima</a> "
else
    NEXT=
fi
#####################################################################
#As linhas do HTML abaixo podem ser aditadas de acordo com o gosto do
#usuário, podendo este criar o layout desejado
####################################################################


echo  "
<html>
<head><title>${NOME_ALBUM}  $i </title></head>

<body>
<table>
  <tr>
    <td align=\"center\" colspan=3>${TITULO}</td>
  </tr>
  <tr>
    <td></td>
    <td>${FOTO_LINK}</td>
    <td></td></tr>
  <tr>
    <td>${PREV}</td>
    <td align=\"center\"><a href=../index.html>index</a> </td>
    <td>${NEXT}</td>
  </tr>
</table>
</body>
</html>" > ${DIR_HTML}/${nome}.html


  i=$(($i +1))

done

#####################################################
#Criação do index.html - Indice das fotos
#####################################################

echo "Criando index"

echo "
<html>
<head><title>${NOME_ALBUM}  $i </title></head>

<body>
<table>
  <tr>
    <td align=\"center\" colspan=${COLUNAS}>${TITULO}</td>
  </tr>
  <tr> " >  ${DIR_DEST}/index.html

#######################################################
# While que imprime os links das fotos
#######################################################
i=1
while (($quant >= $i))
do
nome=`printf {%0${form}d,$i}`
FOTO_LINK="<a href='${DIR_HTML_S}${nome}.html'><img border='0' src=\"${DIR_THUMB_S}${nome}.${EXT}\"></a>"

echo -e "<td>$FOTO_LINK</td>" >> ${DIR_DEST}/index.html

######################################################
# Neste ponto, o Shell divide as colunas, imprimindo
# um <tr></tr> quando já tiver imprimido $COLUNAS fotos
######################################################
if ((${i}%${COLUNAS}==0));then
echo -e "</tr><tr>"  >> ${DIR_DEST}/index.html
fi

i=$(($i+1))

done
#######################################################
# Fim do While
#######################################################


echo "
  </tr>
</table>
</body>
</html>"  >> ${DIR_DEST}/index.html

echo "OK"

exit 0
