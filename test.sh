#!/bin/bash
if [ $# -eq 1 -a "$1" = "-f" ]; then
  hugo server --disableFastRender
  exit 0
fi
hugo server
