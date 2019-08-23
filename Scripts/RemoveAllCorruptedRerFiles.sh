#!/bin/bash
# This script goes through all reference simulation subdirectories and removes all files with specified extention in first argument that do not have n lines in them, n being defined by the second argument

Ext=$1
Nlines=$2

for i in */*/*/*/*.${Ext}
do 
    WC=$(wc -l $i | awk '{print $1}')
    if [ "$WC" != "$Nlines" ] && [ "$WC" != "wc:" ]
    then 
        rm $i
    fi
done