#!/bin/bash
# This script runs a bunch of GOMC (reference) simulations and waits until all of them are done
# Example:
# bash $HOME/Git/TranSFF/Scripts/RUN_PARTICLES_AND_WAIT.sh.sh "I-1_P-1 I-1_P-2" C4 "0.4873/361.43 0.6335/241.55 0.6822/191.34 510.16/0.0975 510.16/0.4873 510.16/0.6335 510.16/0.6822" FSHIFT_BULK_SHORT.conf 7 "3.76-120.5_3.99-58.55 3.75-118.6_3.95-55.9"

keyword_array=$1
molecule=$2
selected_itic_points=$3
config_filename=$4
Nproc=$5
sig_eps_nnn_array=$6

keyword_array=($keyword_array)
sig_eps_nnn_array=($sig_eps_nnn_array)

for i in $(seq 0 $(echo "${#sig_eps_nnn_array[@]}-1" | bc)) # Iterate through sites
do
	generate_par_output=$(bash $HOME/Git/TranSFF/Scripts/generate_par.sh "${keyword_array[i]}" "${molecule}" "there" "${sig_eps_nnn_array[i]}")
	sim_name[i]=$(echo $generate_par_output | awk '{print $1}')
	par_file_name[i]=$(echo $generate_par_output | awk '{print $2}')

	#mkdir "${keyword_array[i]}_${sim_name[i]}"
	#cd "${keyword_array[i]}_${sim_name[i]}"
	mkdir "${keyword_array[i]}_${sig_eps_nnn_array[i]}"
	cd "${keyword_array[i]}_${sig_eps_nnn_array[i]}" 
		cp $HOME/Git/TranSFF/Molecules/${molecule}/${molecule}_Files.zip .
		unzip ${molecule}_Files.zip
		rm ${molecule}_Files.zip 
		bash $HOME/Git/TranSFF/Scripts/RunITIC_GOMC_Parallel.sh "${molecule}" "${par_file_name[i]}" "$config_filename" "$selected_itic_points" "yes" "$Nproc" &
	cd ..
done

wait