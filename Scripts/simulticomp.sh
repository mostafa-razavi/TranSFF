#!/bin/bash
CD=${PWD}

sig_eps_nnn0=$1
prefix=$2

molecules_array="IC4 NP"
all_ref_array[0]="3.780-123.00_4.730-25.00 3.790-120.00_4.680-10.00 3.810-122.00_4.660-16.00 3.820-120.00_4.720-18.00 3.840-118.00_4.740-20.00"
all_ref_array[1]="3.780-123.00_6.320-5.00 3.790-120.00_6.340-10.00 3.810-122.00_6.350-8.00 3.820-120.00_6.280-3.00 3.840-118.00_6.260-6.00"

config_filename="FSHIFT_2M.conf"
datafile_keyword="REFPROP"
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

    raw_par_path="$HOME/Git/TranSFF/Forcefields/TranSFF0_Alkanes_SOME.par"
    select_itic_points=$(cat $HOME/Git/TranSFF/Molecules/${molec}/${molec}_select9.trho)
    data_file="$HOME/Git/TranSFF/Data/${molec}/${datafile_keyword}_select9.res"

    eval "bash $HOME/Git/TranSFF/Scripts/simulticomp_pre.sh $key ${molec} \"$select_itic_points\" $config_filename $Nproc ${sig_eps_nnn[i]} \"$ref_array\" $data_file ${datafile_keyword} $raw_par_path $GOMC_exe $z_wt $u_wt $n_wt" "$Nsnapshots" "$rerun_inp" "$number_of_lowest_Neff" "$target_Neff"
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
        bash $HOME/Git/TranSFF/Scripts/simulticomp_post.sh $key ${molec} "$select_itic_points" $config_filename $Nproc "${sig_eps_nnn[i]}" "$ref_array" $HOME/Git/TranSFF/Data/${molec}/${datafile_keyword}_select9.res ${datafile_keyword} $GOMC_exe $z_wt $u_wt $n_wt "$Nsnapshots" "$rerun_inp" "$number_of_lowest_Neff" "$target_Neff" &
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