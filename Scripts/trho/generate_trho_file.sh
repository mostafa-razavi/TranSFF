#!/bin/bash

round() {
  printf "%.${2}f" "${1}"
}

select_what="select9"
forcefield="REFPROP"
inFile="${forcefield}_${select_what}.res"

for iMolec in *
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

