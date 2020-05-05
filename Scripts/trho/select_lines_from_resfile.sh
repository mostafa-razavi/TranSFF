#!/bin/bash
#select_which="1 2 6 10 17 19 21 23 25 27" #select9
#select_which="1 4 10 16 20 24 27" #select6
#select_which="1 2 6 10 17 19 21" #select6sat3lowrho3
#select_which="1 2 6 10" #select3sat3
#select_which="1 2 10 17" #select3sat2lowrho1
#select_which="1 2 10 17 20" #select4
#select_which="1 2 6 10 17 20" #select5sat3lowrho2
#select_which="1 2 10 17 21" #select4_2-10-17-21
select_which="1 2 10 18 20" #select4_2-10-18-20

select_what="select4_2-10-18-20"

for iFF in REFPROP TraPPE MiPPE TraPPE-SWF MiPPE-SWF
do
    for i in */
    do
        rm -rf ${i}${iFF}_${select_what}.res
        for l in $select_which
        do
            if [ -e "${i}${iFF}.res" ]; then
                sed "${l}q;d" ${i}${iFF}.res >> ${i}${iFF}_${select_what}.res
            fi
        done
    done
done