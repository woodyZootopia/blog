#!/bin/bash
cp ./static/img/logo2.jpg ./themes/hugo-icarus-theme/static/css/images/logo2.jpg #overwrite with my logo
if [ $# -eq 1 -a "$1" = "-f" ]; then
  hugo server --disableFastRender
  exit 0
fi
hugo server
