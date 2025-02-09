#!/bin/bash

if ! command -v fpc &> /dev/null
then
    echo "fpc could not be found."
    echo "verify that the compiler is in your path."
    echo "abort."
    exit
fi

for f in *.pas
do
    fpc $f -Fu../src
done
