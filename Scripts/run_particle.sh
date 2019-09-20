#!/bin/bash
# This script runs a bunch of GOMC (rerun) simulations and waits until all of them are done
# Example:
# bash $HOME/Git/TranSFF/Scripts/run_particles_and_wait.sh "I-1_P-1 I-1_P-2" C4 "0.4873/361.43 0.6335/241.55 0.6822/191.34 510.16/0.0975 510.16/0.4873 510.16/0.6335 510.16/0.6822" FSHIFT_BULK_SHORT.conf 7 "3.76-120.5_3.99-58.55 3.75-118.6_3.95-55.9"

keyword=$1
molecule=$2
selected_itic_points=$3
config_filename=$4
Nproc=$5
sig_eps_nnn=$6
reference_foldernames_array=$7
true_data_file=$8 #"$HOME/Git/TranSFF/Data/C2/REFPROP_select4.res" 
true_data_label=$9 #"REFPROP"                                                              

mkdir "${keyword}"
generate_par_output=$(bash $HOME/Git/TranSFF/Scripts/generate_par.sh "${keyword}" "${molecule}" "here" "${sig_eps_nnn}")
sim_name=$(echo $generate_par_output | awk '{print $1}')
par_file_name=$(echo $generate_par_output | awk '{print $2}')
bash $HOME/Git/TranSFF/Scripts/ReRunITIC_GOMC_Parallel.sh "$keyword" "${molecule}" "$selected_itic_points" "${par_file_name}" "$config_filename" "$Nproc" "$reference_foldernames_array" "$true_data_file" "$true_data_label"
