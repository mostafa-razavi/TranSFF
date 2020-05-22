#!/bin/bash
molec=$1
vle_data_file=$2
outfile=$3

temperatures=$(cat $vle_data_file | tail -n +2 | awk '{print$1}')
first_line="T[K] ρL[gcc] P[Mpa] Hvap[KJ/mol]"
 
ITICfile="$HOME/Git/TranSFF/Molecules/${molec}/${molec}.itic"
CASN=$(grep 'CASN:' ${ITICfile} | awk '{print $2}')

echo $first_line > $outfile
for T in ${temperatures[@]}
do
    keyword=$(date +"%Y.%m.%d.%H.%M.%S.%N")
    rm -rf ${keyword}.temp
    output=$($HOME/Git/DipprSatProp/DipprSatProp $CASN $T 2 $T "${keyword}.temp" | tail -n1 | head -n1)
    rm -r ${keyword}.temp

    psat=$(echo $output | awk '{print$2}')
    rhoL=$(echo $output | awk '{print$3}')
    hvap=$(echo $output | awk '{print$4}')
    echo $T $rhoL $psat $hvap >> $outfile
done

python3.6 $HOME/Git/TranSFF/Scripts/ITIC/calc_deviations_from_dippr.py $vle_data_file $outfile
#python3.6 $HOME/Git/TranSFF/Scripts/ITIC/calc_deviations_from_dippr_rmsd.py $vle_data_file $outfile
