#!/bin/bash
OutFile=$1

CD=${PWD}

for folder in */
do 
    IFS='-_/' read -ra element <<< "${folder}"
    if [ "${element[4]}" != "i" ]; then
        ref_I+=(${element[1]})
        ref_P+=(${element[3]})
        ref_sig1+=(${element[4]})
        ref_eps1+=(${element[5]})
        #ref_sig2+=(${element[6]})
        #ref_eps2+=(${element[7]})        
        SCORE=$(cat $folder/*.SCORE)
        REF_SCORE_ARRAY+=("${SCORE}")        
    fi

done 
 
rm -rf ${CD}/${OutFile}
echo "I	P	i	p	ref_sig1	ref_eps1	TOTAL_SCORE	Z_SCORE	U^RES_SORE	MBAR_Sig1	MBAR_Eps1	Total_Score	Z_score	U^res_Score	Neff_Score(Target=50)" >> ${CD}/${OutFile}
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
        #sig2=${element[14]}
        #eps2=${element[16]}        
        score=$(cat $ifol/*.score)
        if [ "$score" != "" ]; then
            echo ${element[1]} ${element[3]} ${element[5]} ${element[7]} ${ref_sig1[iref]} ${ref_eps1[iref]} ${REF_SCORE_ARRAY[iref]} $sig1 $eps1 $score >> ${CD}/${OutFile}
        else
            echo "No score file was found in ${ifol}"
        fi
    done
done

sort -k1 -k2 -k3 -k4 -n -o ${CD}/${OutFile} ${CD}/${OutFile}
