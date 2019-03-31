#!/bin/bash

# move all images to rawimages directory
find content -name '*.png' | while read f
do
    relfileplace=${f%.*}
    reldirplace=${relfileplace%/*}
    mkdir -p ./rawimages/$reldirplace
    mv "./${relfileplace}.png" "./rawimages/${relfileplace}.png"
done

# convert to jpg and write them to each directory
find rawimages -name '*.png' | while read f
do
    filewithoutext=${f%.*}
    relfileplace=${filewithoutext#*/}

    if [ "$1" != "-f" ] || [ ! -f  "./${relfileplace}.jpg" ] ;then
        break
    fi

    if command convert 2> /dev/null > /dev/null; then
        convert "./rawimages/${relfileplace}.png" "./${relfileplace}.jpg"

    elif command sips 2> /dev/null > /dev/null; then
        sips -s format jpeg "./rawimages/${relfileplace}.png" -s formatOptions low --out "./${relfileplace}.jpg"
    else
        echo "known conversion command not found"
        exit 1
    fi
done

