#!/bin/bash
CD=${PWD}

sig_eps_nnn0=$1
prefix=$2

molecules_array="C2 C4 C8 C12"
all_ref_array[0]="3.81-127 3.79-134 3.78-131 3.77-133 3.75-129" #C2 
all_ref_array[1]="3.81-127_3.95-74 3.79-134_3.97-67 3.78-131_3.99-70 3.77-133_4.01-68 3.75-129_4.03-72" #C4
all_ref_array[2]="3.81-127_3.95-74 3.79-134_3.97-67 3.78-131_3.99-70 3.77-133_4.01-68 3.75-129_4.03-72" #C8
all_ref_array[3]="3.81-127_3.95-74 3.79-134_3.97-67 3.78-131_3.99-70 3.77-133_4.01-68 3.75-129_4.03-72" #C12

raw_par_path="$HOME/Git/TranSFF/Forcefields/MiPPE-GEN_Alkanes_SOME.par"
datafile_keyword="MiPPE"
GOMC_exe="$HOME/Git/GOMC/GOMC-FSHIFT2-SWF-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"
n_closest="5"
z_wt="0.60"
u_wt="0.40"
n_wt="0.0001"
Nsnapshots="500"
rerun_inp="none"                                                                                 # "none" or filename
number_of_lowest_Neff="1"
target_Neff="25"
Nproc=$(nproc)


sig_eps_nnn[0]=$sig_eps_nnn0
sig_eps_nnn[1]=$sig_eps_nnn0
sig_eps_nnn[2]=$sig_eps_nnn0
sig_eps_nnn[3]=$sig_eps_nnn0



i=-1
molecules_array=($molecules_array)
for molec in "${molecules_array[@]}"
do 
    i=$((i+1))
    cd ${CD}/${molec}
    #ref_array=$(python3.6 ${CD}/get_closest_references.py "$sig_eps_nnn" "${all_ref_array[i]}" "$n_closest")
    ref_array="${all_ref_array[i]}"

    #key="${prefix}_${sig_eps_nnn[i]}"
    key="${prefix}"
    echo "${prefix}_${sig_eps_nnn[i]}" "$ref_array" >> $CD/reference_list.log        

    select_itic_points=$(cat $HOME/Git/TranSFF/Molecules/${molec}/${molec}_select9.trho)
    data_file="$HOME/Git/TranSFF/Data/${molec}/${datafile_keyword}_select9.res"

    eval "bash $HOME/Git/TranSFF/Scripts/simulticomp_pre.sh $key ${molec} \"$select_itic_points\" $Nproc ${sig_eps_nnn[i]} \"$ref_array\" $data_file ${datafile_keyword} $raw_par_path $GOMC_exe $z_wt $u_wt $n_wt" "$Nsnapshots" "$rerun_inp" "$number_of_lowest_Neff" "$target_Neff"
done

rm -rf "$CD/COMMANDS.parallel"
cd $CD
bash $HOME/Git/nestplore/nestplore.sh 1 "cat ${key}.parallel" >> "$CD/COMMANDS.parallel"

parallel --willcite --jobs $Nproc < "$CD/COMMANDS.parallel"

i=-1
for molec in "${molecules_array[@]}"
do 
    i=$((i+1))
    cd ${CD}/${molec}
    ref_array="${all_ref_array[i]}"
    select_itic_points=$(cat $HOME/Git/TranSFF/Molecules/${molec}/${molec}_select9.trho)
    #key="${prefix}_${sig_eps_nnn[i]}"
    key="${prefix}"
    if [ -e "$key" ]; then
        echo "There is a folder associated to this parameter set. simulticomp_post.sh script will not run!"
    else
        bash $HOME/Git/TranSFF/Scripts/simulticomp_post.sh $key ${molec} "$select_itic_points" $Nproc "${sig_eps_nnn[i]}" "$ref_array" $HOME/Git/TranSFF/Data/${molec}/${datafile_keyword}_select9.res ${datafile_keyword} $raw_par_path $GOMC_exe $z_wt $u_wt $n_wt "$Nsnapshots" "$rerun_inp" "$number_of_lowest_Neff" "$target_Neff" &
    fi
done

wait

rm -rf $CD/${sig_eps_nnn0}.score
echo "molec Total_Score Z_score U^res_Score Neff_Score" >> $CD/${sig_eps_nnn0}.score
for molec in "${molecules_array[@]}"
do 
    score=$(cat ${CD}/${molec}/${prefix}_${sig_eps_nnn0}/*.score)
    echo $molec $score >> $CD/${sig_eps_nnn0}.score
done

echo $CD/${sig_eps_nnn0}.score