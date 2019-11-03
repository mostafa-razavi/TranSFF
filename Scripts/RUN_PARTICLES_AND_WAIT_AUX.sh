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
Z_WT=$7
U_WT=$8
true_data_file=$9
true_data_label=${10}
raw_par=${11}

keyword_array=($keyword_array)
sig_eps_nnn_array=($sig_eps_nnn_array)

for i in $(seq 0 $(echo "${#sig_eps_nnn_array[@]}-1" | bc)) # Iterate through sites
do
	if [ ! -e "${keyword_array[i]}_${sig_eps_nnn_array[i]}" ]; then
		generate_par_output=$(bash $HOME/Git/TranSFF/Scripts/generate_par3.sh "${keyword_array[i]}" "${molecule}" "there" "${sig_eps_nnn_array[i]}" 2 "$raw_par")
		sim_name[i]=$(echo $generate_par_output | awk '{print $1}')
		par_file_name[i]=$(echo $generate_par_output | awk '{print $2}')

		mkdir "${keyword_array[i]}_${sig_eps_nnn_array[i]}"
		cd "${keyword_array[i]}_${sig_eps_nnn_array[i]}" 
			cp $HOME/Git/TranSFF/Molecules/${molecule}/${molecule}_Files.zip .
			unzip ${molecule}_Files.zip
			rm ${molecule}_Files.zip 
			bash $HOME/Git/TranSFF/Scripts/RunITIC_GOMC_Parallel.sh "${molecule}" "${par_file_name[i]}" "$config_filename" "$selected_itic_points" "yes" "$Nproc" &
		cd ..
	else
		echo "The reference simulation" "${keyword_array[i]}_${sig_eps_nnn_array[i]}" "was used. No simulation will be run."
	fi
done

wait

MW=$(grep "MW:" $HOME/Git/TranSFF/Molecules/${molecule}/${molecule}.itic | awk '{print $2}')

for i in $(seq 0 $(echo "${#sig_eps_nnn_array[@]}-1" | bc)) # Iterate through sites
do
	echo
	cd "${keyword_array[i]}_${sig_eps_nnn_array[i]}" 
		sim_data_file="trhozures.res" 
		SCORE=$(python3.6 $HOME/Git/TranSFF/Scripts/calc_sim_from_true_data_dev.py $MW ${true_data_file} $sim_data_file $Z_WT $U_WT )
		echo $SCORE > "${keyword_array[i]}_${sig_eps_nnn_array[i]}.SCORE"
		python3.6 $HOME/Git/TranSFF/Scripts/plot_sim_vs_true_data.py $MW ${true_data_file} $true_data_label "${keyword_array[i]}_${sig_eps_nnn_array[i]}.png" $sim_data_file
	cd ..
done