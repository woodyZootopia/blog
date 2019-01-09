#!/bin/bash

find content -name '*.png' | while read f
do
    relfileplace=${f%.*}
    filename=${relfileplace##*/}
    absfileplace=`pwd`/${f%.*}
    if [ ! -f "${absfileplace}.jpg" ]
    then
        sips -s format jpeg "${absfileplace}.png" -s formatOptions normal --out "${absfileplace}.jpg"
    fi

    absdirplace=${absfileplace%/*}
    reldirplace=${absdirplace#*blog/}
    newdirplace=./rawfiles/$reldirplace

    mkdir -p "$newdirplace"
    # echo $newdirplace$filename
    mv "${absfileplace}.png" "$newdirplace${filename}.png"
done

