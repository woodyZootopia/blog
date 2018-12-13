#!/bin/bash
cp ./static/img/logo.png ./themes/hugo-icarus-theme/static/css/images/logo.png #overwrite with my logo
if [ $# -eq 1 -a "$1" = "-f" ]
    then rm -rf public/*
fi
hugo
cd public
git add .
msg="rebuilding site `date`"
git commit -m "$msg"
git push origin master
cd ..
