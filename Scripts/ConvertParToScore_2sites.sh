#!/bin/bash
# This script runs GOMC_ITIC_MBAR.sh script for specified sigmas and epsilons as two arrays by modifying the raw_par file.
iteration_name=$1
some_sig_site1=$2
some_eps_site1=$3
some_sig_site2=$4
some_eps_site2=$5

reference_foldernames_array="s3.700e123-s4.100e58 s3.725e123-s4.075e58 s3.750e123-s4.050e58 s3.750e127-s4.100e60 s3.775e123-s4.025e58 s3.775e127-s4.075e60 s3.800e123-s4.000e58 s3.800e127-s4.050e60 s3.825e123-s3.975e58 s3.825e127-s4.025e60 s3.850e123-s3.950e58 s3.850e127-s4.000e60 s3.875e123-s3.925e58 s3.875e127-s3.975e60 s3.900e123-s3.900e58 s3.900e127-s3.950e60 s3.925e127-s3.925e60 s3.950e127-s3.900e60"
Ncore="32"
Nsnapshots="1000"
raw_par="$HOME/Git/TranSFF/Forcefields/C4/C4_sSOMEeSOME-sSOMEeSOME.par"
rerun_inp="none"                                                                                 # "none" or filename
GOMC_exe="$HOME/Git/GOMC/GOMC-FSHIFT2-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"
Selected_Ts="361.43 241.55 191.34 510.16 510.16 510.16 510.16"                                    # "all" or array
Selected_rhos="0.4873 0.6335 0.6822 0.0975 0.4873 0.6335 0.6822"                                  # "all" or array

MW="58.1222"
true_data_file="$HOME/Git/TranSFF/Data/C2/REFPROP_select7.res" 
true_data_label="REFPROP"                                                              
z_wt="1.0"
u_wt="0.0"


if [ -e "$iteration_name" ]; then echo "$iteration_name folder already exists. Exiting..."; exit; fi

par_file_name="s${some_sig_site1}e${some_eps_site1}-s${some_sig_site2}e${some_eps_site2}.par"
cp  $raw_par $par_file_name

sed -i "s/some_sig_site1/$some_sig_site1/g" $par_file_name
sed -i "s/some_eps_site1/$some_eps_site1/g" $par_file_name
sed -i "s/some_sig_site2/$some_sig_site2/g" $par_file_name
sed -i "s/some_eps_site2/$some_eps_site2/g" $par_file_name

bash $HOME/Git/TranSFF/Scripts/GOMC_ITIC_MBAR.sh "TFF" "$reference_foldernames_array" $par_file_name $rerun_inp $Nsnapshots $Ncore $GOMC_exe "$Selected_Ts" "$Selected_rhos"


rm -rf "${iteration_name}.parallel"
cat *.parallel >> "${iteration_name}.parallel"
parallel --willcite --jobs $Ncore < "${iteration_name}.parallel" > "${iteration_name}.log"

 
bash $HOME/Git/TranSFF/Scripts/GOMC_ITIC_MBAR.sh "FFT" "$reference_foldernames_array" $par_file_name $rerun_inp $Nsnapshots $Ncore $GOMC_exe "$Selected_Ts" "$Selected_rhos"


mbar_data_file=$(ls *.target.res)
score=$(python3.6 $HOME/Git/TranSFF/Scripts/calc_mbar_from_true_data_dev.py $MW ${true_data_file} $mbar_data_file $z_wt $u_wt)
echo $score > ${iteration_name}.score
python3.6 $HOME/Git/TranSFF/Scripts/plot_mbar_vs_true_data.py $MW ${true_data_file} $mbar_data_file ${true_data_label} ${mbar_data_file}.png


mkdir $iteration_name 

mv *.parallel $iteration_name
mv *.res $iteration_name
mv *.log $iteration_name
mv *.par $iteration_name
mv *.score $iteration_name
mv *.png $iteration_name
if [ "$rerun_inp" != "none" ]; then mv $rerun_inp $iteration_name; fi