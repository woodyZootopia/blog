#!/bin/bash

find content -name '*.png' | while read f
do
    filename=${f%.*}
    fileplace=`pwd`/${f%.*}
    if [ ! -f "${fileplace}.jpg" ]
    then
        sips -s format jpeg "${fileplace}.png" -s formatOptions normal --out "${fileplace}.jpg"
        mv ${fileplace}.jpg ./rawfiles/${filename}.jpg
    fi
done

