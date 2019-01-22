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

    sips -s format jpeg "./rawimages/${relfileplace}.png" -s formatOptions low --out "./${relfileplace}.jpg"
done

