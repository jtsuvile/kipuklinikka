#!/bin/bash
echo "making folder $1 for data"
mkdir -p $1/data/
echo "unpacking to $1"
tar xvC ./ -f data.tar
mv -R ./var/www/bml.becs.aalto.fi/keholliset_tuntemukset/ $1/data/