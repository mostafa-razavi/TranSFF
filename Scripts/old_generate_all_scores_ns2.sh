#!/bin/bash

ref_sig1=()
for folder in */
do 
    IFS='-_/' read -ra element <<< "${folder}"
    if [ "${element[4]}" != "i" ]; then
        ref_I+=(${element[1]})
        ref_P+=(${element[3]})
        ref_sig1+=(${element[4]})
        ref_eps1+=(${element[5]})
        ref_sig2+=(${element[6]})
        ref_eps2+=(${element[7]})        
    fi

done 

rm -rf All_scores.res
echo "I	P	i	p	ref_sig1	ref_eps1	ref_sig2	ref_eps2	MBAR_Sig1	MBAR_Eps1	MBAR_Sig2	MBAR_Eps2	Total_Score	Z_score	U^res_Score	Neff_Score(Target=50)" >> All_scores.res
for iref in $(seq 0 $(echo "${#ref_sig1[@]}-1" | bc))	
do
    for ifol in I-${ref_I[iref]}_P-${ref_P[iref]}_i*/
    do
        folder=$(echo $ifol)
        cd $folder
        par_file=$(ls *.par)
        par_file="${par_file%.*}"

        cd ..
        IFS='-_se' read -ra element <<< "$par_file"
        sig1=${element[10]}
        eps1=${element[12]}
        sig2=${element[14]}
        eps2=${element[16]}        
        score=$(cat $ifol/*.score)
        echo ${element[1]} ${element[3]} ${element[5]} ${element[7]} ${ref_sig1[iref]} ${ref_eps1[iref]} ${ref_sig2[iref]} ${ref_eps2[iref]} $sig1 $eps1 $sig2 $eps2 $score >> All_scores.res
        #echo ${element[0]} ${element[1]} ${element[2]} ${element[3]} ${element[4]} ${element[5]} ${element[6]} ${element[7]} ${element[8]} ${element[9]} ${element[10]} ${element[12]}
    done
done

 