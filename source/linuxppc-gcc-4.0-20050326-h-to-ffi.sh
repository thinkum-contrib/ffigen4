#!/bin/sh
FFIGEN_DIR=`dirname $0`/../ffigen
CFLAGS="-isystem ${FFIGEN_DIR}/ginclude -isystem /usr/include -isystem /usr/local/include -quiet -fffigen"
GEN=${FFIGEN_DIR}/bin/ffigen


