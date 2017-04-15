#!/bin/bash
for i in *.JPG; do 
	convert -resize 1000x1000 -quality 85 $i `basename $i .png`-klein.png
done

for i in *.JPG; do 
	convert -resize 1000x1000 -quality 85 $i ${i%.JPG}-klein.png
done
