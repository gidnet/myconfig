#!/bin/bash 

contagem_regressiva ()
{
  if [ $1 -eq 0 ]
  then
     clear
     echo "The Final Countdown !!!"
     sleep 1
     echo "tam-dam-dam-daaaam"
     sleep 1
     echo "tam-nam-nam-nam-naaaam"
     return 0
  fi 

  echo $1
  sleep 1
  clear
  novo_tempo=`expr $1 - 1`
  contagem_regressiva $novo_tempo
} 

clear
contagem_regressiva 5
