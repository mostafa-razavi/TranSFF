#!/bin/bash
CD=${PWD}

#============================== Get arguments ================================
site_sig_eps_nnn=$1
prefix=$2
molecules=$3
raw_par_path=$4
datafile_keywords_string=$5
GOMC_exe=$6
weights_file=$7
ZU_or_onlyU=$8
Nsnapshots=${9}
rerun_inp=${10}
Nproc=${11}
ITIC_subset_name=${12}


molecules_array=($molecules)
datafile_keywords=($datafile_keywords_string)
last_arg=$(echo "11 + ${#molecules_array[@]}" | bc)
j=-1
for ((i = 12; i <= $last_arg; i++ )); do
    j=$((j+1))
    all_ref_array[j]="${!i}"
done

#============================== Pre-process ================================
i=-1
for molec in "${molecules_array[@]}"
do 
    i=$((i+1))
    cd ${CD}/${molec}
    #ref_array=$(python3.6 ${CD}/get_closest_references.py "$site_sig_eps_nnn" "${all_ref_array[i]}" "$n_closest")
    ref_array="${all_ref_array[i]}"

    key="${prefix}"
    echo "${prefix}_${site_sig_eps_nnn}" "$ref_array" >> $CD/reference_list.log        

    select_itic_points=$(cat $HOME/Git/TranSFF/SelectITIC/${molec}_${ITIC_subset_name}.trho)
    data_file="$HOME/Git/TranSFF/Data/${molec}/${datafile_keywords[i]}_${ITIC_subset_name}.res"

    #eval "bash $HOME/Git/TranSFF/Scripts/simulticomp_pre2.sh $key ${molec} \"$select_itic_points\" $Nproc ${site_sig_eps_nnn} \"$ref_array\" $data_file ${datafile_keywords[i]} $raw_par_path $GOMC_exe $z_wt $u_wt $n_wt" "$Nsnapshots" "$rerun_inp" "$number_of_lowest_Neff" "$target_Neff"
    #echo "bash $HOME/Git/TranSFF/Scripts/simulticomp_pre2.sh $key ${molec} \"$select_itic_points\" $Nproc ${site_sig_eps_nnn} \"$ref_array\" $data_file ${datafile_keywords[i]} $raw_par_path $GOMC_exe $z_wt $u_wt $n_wt" "$Nsnapshots" "$rerun_inp" "$number_of_lowest_Neff" "$target_Neff"
    eval "bash $HOME/Git/TranSFF/Scripts/simulticomp_pre2.sh $key ${molec} \"$select_itic_points\" $Nproc ${site_sig_eps_nnn} \"$ref_array\" $data_file ${datafile_keywords[i]} $raw_par_path $GOMC_exe $ZU_or_onlyU" "$Nsnapshots" "$rerun_inp"
    echo "bash $HOME/Git/TranSFF/Scripts/simulticomp_pre2.sh $key ${molec} \"$select_itic_points\" $Nproc ${site_sig_eps_nnn} \"$ref_array\" $data_file ${datafile_keywords[i]} $raw_par_path $GOMC_exe $ZU_or_onlyU" "$Nsnapshots" "$rerun_inp"     
    echo
done


#============== Generate input file for Gnu Parallel ================
IFS='-_' read -ra element <<< "$prefix"
iteration_pefix="${element[0]}-${element[1]}"
#rm -rf "$CD/${prefix}_COMMANDS.parallel"
for molec in "${molecules_array[@]}"
do 
    cat ${CD}/${molec}/${prefix}*.target.parallel >> "$CD/${prefix}_COMMANDS.parallel"
done


#============================== Rerun ================================
parallel --willcite --jobs $Nproc < "$CD/${prefix}_COMMANDS.parallel"


#============================== Post-process ================================
i=-1
for molec in "${molecules_array[@]}"
do 
    i=$((i+1))
    cd ${CD}/${molec}
    ref_array="${all_ref_array[i]}"
    select_itic_points=$(cat $HOME/Git/TranSFF/SelectITIC/${molec}_${ITIC_subset_name}.trho)
    key="${prefix}"
    if [ -e "$key" ]; then
        echo "There is a folder associated to this parameter set. simulticomp_post2.sh script will not run!"
    else
        #bash $HOME/Git/TranSFF/Scripts/simulticomp_post2.sh $key ${molec} "$select_itic_points" $Nproc "${site_sig_eps_nnn}" "$ref_array" $HOME/Git/TranSFF/Data/${molec}/${datafile_keywords[i]}_${ITIC_subset_name}.res ${datafile_keywords[i]} $raw_par_path $GOMC_exe $z_wt $u_wt $n_wt "$Nsnapshots" "$rerun_inp" "$number_of_lowest_Neff" "$target_Neff" &
        bash $HOME/Git/TranSFF/Scripts/simulticomp_post2.sh $key ${molec} "$select_itic_points" $Nproc "${site_sig_eps_nnn}" "$ref_array" $HOME/Git/TranSFF/Data/${molec}/${datafile_keywords[i]}_${ITIC_subset_name}.res ${datafile_keywords[i]} $raw_par_path $GOMC_exe $weights_file "$Nsnapshots" "$rerun_inp" &
    fi
done
wait

#============================== Compile score files ================================
rm -rf $CD/${site_sig_eps_nnn}.score
echo "molec Total_Score Z_score U^res_Score Neff_Score" >> $CD/${prefix}.score
for molec in "${molecules_array[@]}"
do 
    score=$(cat ${CD}/${molec}/${prefix}_${site_sig_eps_nnn}/*.score)
    echo $molec $score >> $CD/${prefix}.score
done
echo $CD/${site_sig_eps_nnn}.score