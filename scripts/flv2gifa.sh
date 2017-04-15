#!/bin/bash
url=http://www.youtube.com/watch?v=V5bYDhZBFLA
youtube-dl -b $url
mplayer $(ls ${url##*=}*| tail -n1) -ss 00:57 -endpos 10 -vo gif89a:fps=5:output=output.gif -vf scale=400:300 -nosound

mplayer video.flv -ss 00:23 -endpos 6 -vo gif89a:fps=5:output=output.gif -vf scale=400:300 -nosound

