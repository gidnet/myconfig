#!/bin/bash

## Este script é usado para fazer ripagem de DVD em alta qualidade incluindo os marcadores de capítulo e
## legendas. Ele usa Handbrake.
## Contém os melhores parâmetros pra ripagem de alta qualidade e
## também definição de parâmetros simples.
##
## Avi Alkalay <avi at unix dot sh>
## http://avi.alkalay.net/2008/03/mpeg4-dvd-rip.html
##
## $Id$
##

#set -vx

HANDBRAKE=${HANDBRAKE:=~/bin/HandBrakeCLI}
#HANDBRAKE=${HANDBRAKE:="/cygdrive/c/Program Files/Handbrake/HandBrakeCLI.exe"}
## Localização do executável codificador Handrake.
## Download HandBrake para Linux, Mac or Windows at http://HandBrake.fr

INPUT=${INPUT:=/dev/dvd}
## Também pode ser montada uma imagem DVD ou simplesmente '/dev/dvd'

TITLE=${TITLE:=L}
## O número do título a ripar, vázio ou "L" para obter o maior.

#CHAPTERS=${CHAPTERS:=7}
## Examplo: 0 ou indefinido (todos os capitulos), 7 (só capítulo 7), 3-6 (capítulos 3 a 6)

#VERBOSE=${VERBOSE:="yes"}
## O tempo descrito durante o processamento.

SIZE=${SIZE:=1200}
## Tamanho do arquivo destino em MB. Maior o tamanho do arquivo, melhor qualidade.
## Podendo variar entre 1000MB a 1400MB para ripagens de surpreendente alta qualidade em H.264.

OUTPUT=${OUTPUT:="/tmp/output.mkv"}
## Arquivo de saída. Isso também irá definir o formato de arquivo.
## MKV (Matroska) é atualmente o melhor mas  MP4 também é bom.

AUDIO=${AUDIO:="-E ac3 -6 dpl2 -D 1"} # Para AC3 passthru (copia).
#AUDIO=${AUDIO:="-E lame -B 160"} # Para recodificar MP3. Bom quando a entrada é DTS.
## Parametros de áudio. Se entrada for AC3, usar sem transcodificação.
## Se for DTS, recodificar para MP3.

MATRIX=${MATRIX:=`dirname $0`/eqm_avc_hr.cfg}
## x264 matrix de usoe. O arquivo matriz pode aumentar a velocidade de codificação e qualidade.
## Este é um Sharktooth's como encontrado
## no http://forum.doom9.org/showthread.php?t=96298

######### Não altere nada abaixo desta linha ##############

## Fazer cálculos sobre o título e os capítulos com base em parâmetros.
SEGMENT=""
if [[ "$TITLE" == "L" || -z "$TITLE" ]]; then
	SEGMENT="-L"
else
	SEGMENT="-t $TITLE"
fi

[[ -n "$CHAPTERS" && "$CHAPTERS" -ne 0 ]] && SEGMENT+=" -c $CHAPTERS"

[[ "$VERBOSE" != "no" ]] && VERB="-v"

# Define args para o x264 encoder. Estes são alguns valores encontrados na  net
# Com exelentes resultados.
X264ARGS="ref=3:mixed-refs:bframes=6:b-pyramid=1:bime=1:b-rdo=1:weightb=1"
X264ARGS+=":analyse=all:8x8dct=1:subme=6:me=umh:merange=24:filter=-2,-2"
X264ARGS+=":ref=6:mixed-refs=1:trellis=1:no-fast-pskip=1"
X264ARGS+=":no-dct-decimate=1:direct=auto"
[[ -n "$MATRIX" ]] && X264ARGS+=":cqm=$MATRIX"

# Encode...
"$HANDBRAKE" $VERB -i "$INPUT" -o "$OUTPUT" \
	-S $SIZE \
	-m $SEGMENT \
	$AUDIO \
	-e x264 -2 -T -p \
	-x $X264ARGS

# Reempacotar para optimizar o tamanho do arquivo, incluir busca e incluir este
# script como forma de ripar...
echo $OUTPUT | grep -qi ".mkv"
if [[ $? && -x `which mkvmerge` && -f $OUTPUT ]]; then
	mv $OUTPUT $OUTPUT.mkv
	mkvmerge -o $OUTPUT $OUTPUT.mkv \
		--attachment-name "O script ripador" \
		--attachment-description "Como este filme foi criado aprtir de DVD original" \
		--attachment-mime-type application/x-sh \
		--attach-file $0

	[[ -f $OUTPUT ]] && rm $OUTPUT.mkv
fi
