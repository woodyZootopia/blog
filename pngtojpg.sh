#!/bin/bash

find content -name '*.png' | while read f
do
    filename=`pwd`/${f%.*}
    if [ ! -f "${filename}.jpg" ]
    then
        sips -s format jpeg "${filename}.png" -s formatOptions normal --out "${filename}.jpg"
    fi
done

