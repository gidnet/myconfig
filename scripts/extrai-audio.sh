#!/bin/bash
# extrai-audio.sh

#-------------------------------------------------------------------------------------
# Versão 1.0 : Elias Bernabé Turchiello - 14/09/2011 : Extrai o áudio de arquivos de vídeo convertendo-os para wav ou mp3



#-------------------------------------------------------------------------------------
# Elias Bernabé Turchiello
# Home: www.turchiellows.xpg.com.br


#-------------------------------------------------------------------------------------
# Criando a variável de ajuda:
ajuda="
 [`basename $0`]
 * USO : `basename $0` [OPÇÃO]
 * Extrai o áudio de arquivos mp4, avi, rmvb, rm, flv, mpg e wmv; convertendo-os para wav ou mp3.
 * Funciona em modo gráfico não sendo necessário executá-lo na linha de comando.
 * Basta dar permissão de execussão ao script e executá-lo.
 * Tenta resolver automaticamente alguma dependência de programas necessários para a execussão correta do script.
 * Coloque os arquivos de vídeo que deseja extrair o áudio dentro de um diretório qualquer, execute o script e selecione este diretório.
 * É capaz de trabalhar arquivos e diretórios contendo espaço no nome.
 * Processa todos os arquivos de vídeo que estiverem dentro do diretório selecionado.
 * Os arquivos de áudio extraidos ficam em um novo subdiretório com o nome de MP3 ou WAVE.
 * Exibe o andamento do processo de extração.

 [OPÇÕES]
 -h    --help         -mostra esta tela de ajuda e sai
 -v    --versão       -mostra a versão, data de criação, o autor, as mudanças da versão e sai
 -e    --exemplo      -mostra exemplos de como executar este script e sai
"

# Prestando ajuda:
case "$1" in
	-h|--help)
	echo "$ajuda"
	echo
	exit 0 ;;
	
	-v|--versão)
	echo 
	echo " [`basename $0`]"
	echo 
	grep '^# Versão ' "$0" | tail -1 | cut -d : -f 1 | tr -d \#
	grep '^# Versão ' "$0" | tail -1 | cut -d : -f 2 | tr -d \#
	echo 
	grep '^# Versão ' "$0" | tail -1 | cut -d : -f 3 | tr -d \#
	echo 
	exit 0 ;;
	
	-e|--exemplo)
	echo 
	echo "Voce pode executar este script das seguntes formas:"
	echo "./`basename $0`"
	echo "sh `basename $0`"
	echo "bash `basename $0`"
	echo "`basename $0` (neste caso o diretório onde o script está localizado deve estar listado na variável PATH)"
	echo
	exit 0 ;;
	
	*)
	if test -n "$1" ; then # Ou if [ -n "$1" ]; then
		echo "Opção inválida"
		echo "Utilize [-h, --help] [-v, --versão] ou [-e, --exemplo]"
		echo
		exit 1
	fi ;;
esac


#-------------------------------------------------------------------------------------
# Resolvendo dependências:
# Verificando a distribuição:
# Procurando um terminal:
terminais="
xterm
konsole
yakuake
kterm
eterm
terminal
terminator
"
for x in $terminais ;do
	which $x >&2> /dev/null && encontrado="nao"; continue || terminal=$x encontrado="sim"; break
done 
[ "$encontrado" = "nao" ] || {
echo "
Não foi possivel encontrar um terminal conhecido para resolver as dependências
Por favor instale manualmente um dos seguintes terminais e tente novamente:
xterm
konsole
yakuake
kterm
eterm
terminal
terminator"
# Caso o Xdialog já esteja instalado:
Xdialog --title "`basename $0` $$" --backtitle "ERRO" --fill --msgbox "Não foi possivel encontrar um terminal para resolver as dependências. Por favor instale manualmente um dos seguintes terminais e tente novamente: xterm konsole yakuake kterm eterm terminal terminator" 19 60
exit 1
}
# Verificando se existe o comando sudo:
if which sudo >&2> /dev/null; then
	printf "%-70s[ OK ]\n" "sudo"
else
	echo "
	Você não tem o aplicativo sudo instalado em seu sistema
	Por favor instale-o manualmente para poder presseguir com a execussão do script"
	# Caso o Xdialog já esteja instalado:
	Xdialog --title "`basename $0` $$" --backtitle "ERRO" --fill --msgbox "Você não tem o aplicativo sudo instalado em seu sistema\n\nPor favor instale-o manualmente para poder presseguir com a execussão do script" 19 60
	exit 1
fi
# Definindo a lista de dependências:
dependencia="
xterm
Xdialog
ffmpeg
lame
"
# Verificando a distribuição:
if [ -f /etc/redhat-release ] ; then
	# O sistema é Red Hat:
	# Verificando se possui o yum instalado:
	if which yum >&2> /dev/null ; then
		for x in $dependencia ; do
			if which $x >&2> /dev/null; then
				printf "%-70s[ OK ]\n" $x
			else
				$terminal -e "echo Você não tem o $x instalado em sua máquina & echo Forneça a senha de super-usuário para instalá-lo agora & sudo yum install $x & read sai"
			fi
		done
	else
		for x in $dependencia ; do
			if which $x >&2> /dev/null; then
				printf "%-70s[ OK ]\n" $x
			else
				$terminal -e "echo Você não tem o $x instalado em sua máquina & echo Forneça a senha de super-usuário para instalá-lo agora & sudo urpmi $x & read sai"
			fi
		done
	fi
else
	# O sistema é Debian:
	for x in $dependencia ; do
		if which $x >&2> /dev/null; then
			printf "%-70s[ OK ]\n" $x
		else
			$terminal -e "echo Você não tem o $x instalado em sua máquina & echo Forneça a senha de super-usuário para instalá-lo agora & sudo apt-get install $x & read sai"
		fi
	done
fi




#-------------------------------------------------------------------------------------
# Preparando a variável ifs para ler nomes com espaços:
IFS='
'




#-------------------------------------------------------------------------------------
# Mensagem inicial:
Xdialog --title "`basename $0` $$" --backtitle "BEM VINDO" --fill --yesno "Este script irá extrair o áudio contido em arquivos de vídeo\n\nColoque todos os arquivos de vídeo que deseja extrair o áudio dentro de um diretório qualquer e na próxima janela selecione este diretório\n\nPara um melhor funcionamento do script evite utilizar arquivos que contenham o caracter ponto (.) como separador entre as palavras\n\nDeseja prosseguir agora?" 0 0
if [ $? != 0 ]; then
	exit 0
fi




#-------------------------------------------------------------------------------------
# Capturando o diretório onde estão os arquivos a serem extraídos:
Xdialog --title "`basename $0` $$" --backtitle "Entre no diretório onde estão os arquivos de vídeo" --dselect "$HOME" 0 0 2> /tmp/local-$$
if [ $? != 0 ]; then
	exit 0
fi
origem="`cat /tmp/local-$$`"
rm -f /tmp/local-$$




#-------------------------------------------------------------------------------------
# Escolhendo o tipo de arquivo de áudio a ser convertido:
Xdialog --title "`basename $0` $$" --backtitle "Arquivo de áudio" --fill --menu "Escolha o tupo de arquivo de áudio que deseja criar após a extração" 15 40 0 \
"MP3" "" \
"WAVE" "" 2> /tmp/extensao-$$
if [ $? != 0 ]; then
	exit 0
fi
audio=`cat /tmp/extensao-$$`
rm -f /tmp/extensao-$$

# Criando um diretório para armazenar o áudio extraido:
mkdir "$origem$audio"

# Caso tenha escolhido a opção MP3, então escolher a taxa de bits:
if [ "$audio" = "MP3" ]; then
	Xdialog --title "`basename $0` $$" --backtitle "Taxa de bits MP3" --fill --menu "Escolha a taxa de bits mp3" 15 40 0 \
	"32" "Qualidade de AM" \
	"96" "Qualidade de FM" \
	"128" "Qualidade boa" \
	"160" "Qualidade melhor" \
	"192" "Qualidade excelente" \
	"224" "Mais que excelente, mas torna o arquivo muito grande" \
	"320" "Praticamente sem compactação"  2> /tmp/taxa-$$
	if [ $? != 0 ]; then
		exit 0
	fi
	taxa=`cat /tmp/taxa-$$`
	rm -f /tmp/taxa-$$
fi	

# Preparando a exibição dos resultados:
echo "Iniciando o trabalho de extração e conversão ..." >> /tmp/log-$$
echo >> /tmp/log-$$
xterm -e "tail -f -n1000000000000 /tmp/log-$$" &




#-------------------------------------------------------------------------------------
# Extraindo o áudio:
for x in `ls -1 "$origem"`; do
	# Verificando se o nome não é um diretório
	if [ -d "$origem$x" ]; then
		continue
	fi
	
	# Verificando se é um arquivo válido, .avi .mp4 .rmvb .rm .flv .wmv .mpg:
	extensao=`echo $x | awk -F. '{ print $NF }'`
	case $extensao in
		avi|AVI) echo ;;
		mp4|MP4) echo ;;
		rmvb|RMVB) echo ;;
		rm|RM) echo ;;
		mpg|MPG) echo ;;
		flv|FLV) echo ;;
		wmv|WMV) echo ;;
		*) continue ;;
	esac

	echo "" >> /tmp/log-$$
	echo "Processando => $x" >> /tmp/log-$$
	
	# Extraindo o nome:
	nome=`echo $x | cut -d'.' -f1`
	
	# Extraindo o áudio para wave:
	ffmpeg -i "$origem$x" "$origem$nome.wav"
		if [ $? = 0 ]; then
			echo "Extraindo wave  [ OK ]" >> /tmp/log-$$
		else
			echo "Extraindo wave  [ERRO]" >> /tmp/log-$$
		fi
	
	# Caso tenha escolhido converter para mp3:
	if [ "$audio" = "MP3" ]; then
		# Convertendo para mp3:
		lame "$origem$nome.wav" -b "$taxa"kb "$origem$nome.mp3"
			if [ $? = 0 ]; then
				echo "Convertendo mp3 [ OK ]" >> /tmp/log-$$
			else
				echo "Convertendo mp3 [ERRO]" >> /tmp/log-$$
			fi
		rm -f "$origem$nome.wav"
	fi
done

# Movendo os arquivos de áudio para a nova pasta:
mv "$origem"*.wav "$origem$audio"
mv "$origem"*.mp3 "$origem$audio"

echo "" >> /tmp/log-$$
echo "" >> /tmp/log-$$
echo "Todos os arquivos foram processados" >> /tmp/log-$$
echo -e "\a"
sleep 1
echo -e "\a"
sleep 1
echo -e "\a"
