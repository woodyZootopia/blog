#!/bin/bash
rm -r public/*
cp ./static/img/logo.jpg ./themes/hugo-icarus-theme/static/css/images/logo.jpg #overwrite with my logo
hugo
cd public
git add .
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"
git push origin master
cd ..

