#!/bin/bash
OutFile=$1

if [ "$OutFile" == "" ]; then echo "Please specify a name for the output file. Exiting..."; exit; fi

CD=${PWD}

for folder in `ls -d I-*/ | sort -V`
do 
    folder=${folder::-1}
    IFS='-_/' read -ra element <<< "${folder}"
    if [ "${element[4]}" != "i" ]; then
        ref_I+=(${element[1]})
        ref_P+=(${element[3]})
        ref_sig1+=(${element[4]})
        ref_eps1+=(${element[5]})
        ref_sig2+=(${element[6]})
        ref_eps2+=(${element[7]})  
        ref_sig3+=(${element[8]})
        ref_eps3+=(${element[9]})  
        ref_sig4+=(${element[10]})
        ref_eps4+=(${element[11]})                        
        SCORE=$(cat $folder/*.SCORE)
        REF_SCORE_ARRAY+=("${SCORE}")        
    fi

done 
 
rm -rf ${CD}/${OutFile}
echo "I P i p ref_sig1 ref_eps1 ref_sig2 ref_eps2 ref_sig3 ref_eps3 ref_sig4 ref_eps4 TOTAL_SCORE Z_SCORE U^RES_SORE MBAR_Sig1 MBAR_Eps1 MBAR_Sig2 MBAR_Eps2 MBAR_Sig3 MBAR_Eps3 MBAR_Sig4 MBAR_Eps4 Total_Score Z_score U^res_Score Neff_Score(Target=50)" >> ${CD}/${OutFile}
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
        sig3=${element[17]}
        eps3=${element[18]} 
        sig4=${element[19]}
        eps4=${element[20]}                         
        score=$(cat $ifol/*.score)
        if [ "$score" != "" ]; then
            echo ${element[1]} ${element[3]} ${element[5]} ${element[7]} ${ref_sig1[iref]} ${ref_eps1[iref]} ${ref_sig2[iref]} ${ref_eps2[iref]} ${ref_sig3[iref]} ${ref_eps3[iref]} ${ref_sig4[iref]} ${ref_eps4[iref]} ${REF_SCORE_ARRAY[iref]} $sig1 $eps1 $sig2 $eps2 $sig32 $eps3 $sig4 $eps4 $score >> ${CD}/${OutFile}
        else
            echo "No score file was found in ${ifol}"
        fi
    done
done

sort -k1 -k2 -k3 -k4 -n -o ${CD}/${OutFile} ${CD}/${OutFile}
