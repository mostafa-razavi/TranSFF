#!/bin/bash

ref_sig=()
for folder in */
do 
    IFS='-_/' read -ra element <<< "${folder}"
    if [ "${element[4]}" != "i" ]; then
        ref_I+=(${element[1]})
        ref_P+=(${element[3]})
        ref_sig+=(${element[4]})
        ref_eps+=(${element[5]})
    fi

done 

rm -rf All_scores.res
echo "I	P	i	p	Ref_Sig	Ref_Eps	MBAR_Sig	MBAR_Eps	Total_Score	Z_score	U^res_Score	Neff_Score(Target=50)" >> All_scores.res
for iref in $(seq 0 $(echo "${#ref_sig[@]}-1" | bc))	
do
    for ifol in I-${ref_I[iref]}_P-${ref_P[iref]}_i*/
    do
        folder=$(echo $ifol)
        cd $folder
        par_file=$(ls *.par)
        par_file="${par_file%.*}"

        cd ..
        IFS='-_se' read -ra element <<< "$par_file"
        sig=${element[10]}
        eps=${element[12]}
        score=$(cat $ifol/*.score)
        echo ${element[1]} ${element[3]} ${element[5]} ${element[7]} ${ref_sig[iref]} ${ref_eps[iref]} $sig $eps $score >> All_scores.res
        #echo ${element[0]} ${element[1]} ${element[2]} ${element[3]} ${element[4]} ${element[5]} ${element[6]} ${element[7]} ${element[8]} ${element[9]} ${element[10]} ${element[12]}
    done
done

 