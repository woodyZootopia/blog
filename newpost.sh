#!/bin/bash
if [ $# -lt 1 ]; then
    echo "ERROR: input article title"
    exit 1
fi
hugo new post/$1/index.md
