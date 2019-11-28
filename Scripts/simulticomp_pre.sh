#!/bin/bash

keyword=$1
molecule=$2
selected_itic_points=$3
Nproc=$4
sig_eps_nnn=$5
reference_foldernames_array=$6
true_data_file=$7
true_data_label=$8                                                             
raw_par_path=$9
GOMC_exe=${10}
z_wt=${11}
u_wt=${12}
n_wt=${13}
Nsnapshots=${14}
rerun_inp=${15}
number_of_lowest_Neff=${16}
target_Neff=${17}

generate_par_output=$(bash $HOME/Git/TranSFF/Scripts/generate_par4.sh "nokey" "${molecule}" "here" "${sig_eps_nnn}" "$raw_par_path")
sim_name=$(echo $generate_par_output | awk '{print $1}')
par_file_name=$(echo $generate_par_output | awk '{print $2}')                                                             

echo $par_file_name $sig_eps_nnn

MW=$(grep "MW:" $HOME/Git/TranSFF/Molecules/${molecule}/${molecule}.itic | awk '{print $2}')


if [ "$(echo "$z_wt" | bc)" == 0 ]; then
    ures_or_pures="ures"
else
    ures_or_pures="p_ures"
fi

# Separate Trho pair array into T array and rho array
Selected_Ts=""
Selected_rhos=""
selected_itic_points=($selected_itic_points)

for iRhoOrT in $(seq 0 $(echo "${#selected_itic_points[@]}-1" | bc))	# Loop from 0 to len(Selected_rhos)-1
do
    IFS='/' read -ra element <<< "${selected_itic_points[iRhoOrT]}"
    rho_or_T1=${element[0]}
    rho_or_T2=${element[1]}
    if (( $(echo "$rho_or_T1 < 5" | bc -l) )); then # 5 is just a number too high for density and too low for temperature
        rho=$rho_or_T1
        T=$rho_or_T2
        pair="$rho/$T"
    else
        rho=$rho_or_T2
        T=$rho_or_T1
        pair="$T/$rho"
    fi    

    Selected_Ts="${Selected_Ts} $T"
    Selected_rhos="${Selected_rhos} $rho"
done

bash $HOME/Git/TranSFF/Scripts/GOMC_ITIC_MBAR_3.sh "TFF" "$keyword" "$reference_foldernames_array" $par_file_name $rerun_inp $Nsnapshots $Nproc $GOMC_exe "$Selected_Ts" "$Selected_rhos" "$ures_or_pures"
echo bash $HOME/Git/TranSFF/Scripts/GOMC_ITIC_MBAR_3.sh "TFF" "$keyword" "$reference_foldernames_array" $par_file_name $rerun_inp $Nsnapshots $Nproc $GOMC_exe "$Selected_Ts" "$Selected_rhos" "$ures_or_pures"

rm -rf "${keyword}.parallel"
cat "${keyword}"*".parallel" >> "${keyword}.parallel"
