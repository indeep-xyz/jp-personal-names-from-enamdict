#!/bin/bash

# remote path
R_ARC="http://ftp.monash.edu.au/pub/nihongo/enamdict.gz"

# local path
MY_DIR="`readlink -f "$0" | sed 's!/[^/]*$!!'`"

L_DIR="$MY_DIR/src"
L_ARC="$L_DIR/enamedict.gz"
L_UTF8="$L_DIR/enamedict.utf8.txt"

# - - - - - - - - - - - - - - - - - - - - - - -
# main

# check source file
if [ ! -f "$L_ARC" ]; then

  # if not exists source file
  # - download
  mkdir -p "$L_DIR"
  wget -O "$L_ARC" "$R_ARC"
fi

# check converted file (utf-8)
if [ ! -f "$L_UTF8" ]; then

  # if not exists utf-8 converted file
  # - convert
  gzip -dc "$L_ARC" \
      | iconv - -f EUCJP -t UTF8 > "$L_UTF8"
fi

echo 'source data is available:'
echo "  $L_UTF8"
