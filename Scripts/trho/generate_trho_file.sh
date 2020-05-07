#!/bin/bash

round() {
  printf "%.${2}f" "${1}"
}

select_what="select4_2-10-19-21"
forcefield="TraPPE"
inFile="${forcefield}_${select_what}.res"

for iMolec in 15C6E  1C4E  1C8E  22MB  22MH  22MP  23MB  25MH  2MH  33MH  34MH  C1  C12  C16  C2    C2E  C3  C3E  C4  C5  C8  IC4  IC4E  IC5  IC6  IC8  NP # TraPPE
#for iMolec in 1C5E  1C6E  1C7E # TraPPE-SWF
#for iMolec in t-2C4E c-2C4E # REFPROP
do

    T_IT1=$(grep -R "T_IT:" $HOME/Git/TranSFF/Molecules/${iMolec}/${iMolec}.itic | awk '{print $2}')
    T_IT2=$(grep -R "T_IT:" $HOME/Git/TranSFF/Molecules/${iMolec}/${iMolec}.itic | awk '{print $3}')

    Ts=($(cat ${iMolec}/$inFile | tail -n +2 | awk '{print$1}'))
    Rhos=($(cat ${iMolec}/$inFile | tail -n +2 | awk '{print$2}'))

    i=0   
    string="" 
    for Ts in "${Ts[@]}"
    do
        T=$(round ${Ts[i]} 2)
        rho=$(round ${Rhos[i]} 4)
        if [ "$T" == "$T_IT1" ] || [ "$T" == "$T_IT2" ]; then
            append="$T/$rho"
        else
            append="$rho/$T"
        fi
        string="$string $append"

        i=$((i+1))
    done

    echo $string > ${iMolec}/${iMolec}_${select_what}.trho

done

