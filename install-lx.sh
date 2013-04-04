#!/bin/sh
SKETCHBOOK=`awk '/sketchbook.path/ {print substr($1, 17);}' ~/Library/Processing/preferences.txt`
if [ ${#SKETCHBOOK} -lt 2 ]
then
    SKETCHBOOK=~/Documents/Processing
fi

mkdir -p $SKETCHBOOK/libraries
rm -fr $SKETCHBOOK/libraries/HeronLX
unzip -q external/HeronLX.zip -d $SKETCHBOOK/libraries

