#!/bin/bash
select_which="1 2 6 10 17 19 21 23 25 27" #select9
#select_which="1 4 10 16 20 24 27" #select6
#select_which="1 2 6 10 17 19 21" #select6sat3lowrho3
#select_which="1 2 6 10" #select3sat3
#select_which="1 2 10 17" #select3sat2lowrho1
select_what="select9"
forcefield="TraPPE"

for i in */
do
    for l in $select_which
    do
        if [ -e "${i}${forcefield}.res" ]; then
            sed "${l}q;d" ${i}${forcefield}.res >> ${i}${forcefield}_${select_what}.res
        fi
    done
done