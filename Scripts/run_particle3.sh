#!/bin/bash
# This script runs a bunch of GOMC (rerun) simulations and waits until all of them are done
# Example:
# bash $HOME/Git/TranSFF/Scripts/run_particle.sh "I-1_P-1 I-1_P-2" C4 "0.4873/361.43 0.6335/241.55 0.6822/191.34 510.16/0.0975 510.16/0.4873 510.16/0.6335 510.16/0.6822" FSHIFT_BULK_SHORT.conf 7 "3.76-120.5_3.99-58.55 3.75-118.6_3.95-55.9"

keyword=$1
molecule=$2
selected_itic_points=$3
config_filename=$4
Nproc=$5
sig_eps_nnn=$6
reference_foldernames_array=$7
true_data_file=$8 #"$HOME/Git/TranSFF/Data/C2/REFPROP_select4.res" 
true_data_label=$9 #"REFPROP"                                                              
raw_par=${10}
gomc_exe_address=${11}
Nsnapshots=${12}
rerun_inp=${13}
z_wt=${14}
u_wt=${15}
n_wt=${16}
number_of_lowest_Neff=${17}
target_Neff=${18}

mkdir "${keyword}"
generate_par_output=$(bash $HOME/Git/TranSFF/Scripts/generate_par3.sh "${keyword}" "${molecule}" "here" "${sig_eps_nnn}" 2 "$raw_par")
sim_name=$(echo $generate_par_output | awk '{print $1}')
par_file_name=$(echo $generate_par_output | awk '{print $2}')

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

bash $HOME/Git/TranSFF/Scripts/GOMC_ITIC_MBAR_3.sh "TFF" "$keyword" "$reference_foldernames_array" $par_file_name $rerun_inp $Nsnapshots $Nproc $gomc_exe_address "$Selected_Ts" "$Selected_rhos" "$ures_or_pures"

rm -rf "${keyword}.parallel"
cat "${keyword}"*".parallel" >> "${keyword}.parallel"
parallel --willcite --jobs $Nproc < "${keyword}.parallel" #> "${keyword}.log"

bash $HOME/Git/TranSFF/Scripts/GOMC_ITIC_MBAR_3.sh "FFT" "$keyword" "$reference_foldernames_array" $par_file_name $rerun_inp $Nsnapshots $Nproc $gomc_exe_address "$Selected_Ts" "$Selected_rhos" "$ures_or_pures"

mbar_data_file=$(ls "${keyword}"*".target.res")
score=$(python3.6 $HOME/Git/TranSFF/Scripts/calc_mbar_from_true_data_dev_3.py $MW ${true_data_file} $mbar_data_file $z_wt $u_wt $n_wt $number_of_lowest_Neff $target_Neff)
echo $score > ${keyword}.score
python3.6 $HOME/Git/TranSFF/Scripts/plot_mbar_vs_true_data_2.py $MW ${true_data_file} $mbar_data_file ${true_data_label} ${mbar_data_file}.png

python3.6 $HOME/Git/TranSFF/Scripts/GOMC_MBAR_res_to_trhozures.py $MW $mbar_data_file "${keyword}.trhozures.res"

rm -rf $keyword 
mkdir $keyword 

mv "${keyword}"*".parallel" $keyword
mv "${keyword}"*".res" $keyword
#mv "${keyword}"*".log" $keyword
mv "${keyword}"*".par" $keyword
mv "${keyword}"*".score" $keyword
mv "${keyword}"*".png" $keyword
if [ "$rerun_inp" != "none" ]; then mv $rerun_inp $keyword; fi
