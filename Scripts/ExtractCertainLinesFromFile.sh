#!/bin/bash
# This script goes through all files in the current diectory, extracts the lines specified as arguments, and moves the results to a folder called lines_N1-N2-...-N
N=("$@")
for ifile in *
do
    echo $ifile
    rm -rf temp.txt
    lines=""
    for iLine in ${N[@]}
    do
        lines=$lines"$iLine-"
        sed "${iLine}q;d" $ifile >> temp.txt
    done
    mkdir -p lines_${lines::-1}
    mv temp.txt lines_${lines::-1}/${ifile}
done