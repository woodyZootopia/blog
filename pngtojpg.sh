#!/bin/bash

# move all images to rawimages directory
find content -name '*.png' | while read f
do
    relfileplace=${f%.*}
    filename=${relfileplace##*/}
    absfileplace=`pwd`/${f%.*}
    absdirplace=${absfileplace%/*}
    reldirplace=${absdirplace#*blog/}
    newdirplace=./rawimages/$reldirplace

    mkdir -p "$newdirplace"
    # echo $newdirplace$filename
    mv "${absfileplace}.png" "$newdirplace${filename}.png"
done

# convert to jpg and write them to each directory
find rawimages -name '*.png' | while read f
do
    filewithoutext=${f%.*}
    relfileplace=${filewithoutext#*/}

    sips -s format jpeg "./rawimages/${relfileplace}.png" -s formatOptions normal --out "${relfileplace}.jpg"
    # echo ./rawimages/"$relfileplace".png
    # echo ${relfileplace}.jpg
done
