#!/bin/bash
echo -e "Some Text Line1\nSome Text Line 2"
convert -background none -density 196  -resample 72 -unsharp 0x.5 -font "Courier" text:- -trim +repage -bordercolor white -border 3  text.gif
