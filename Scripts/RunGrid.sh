#!/bin/bash
# This script runs GOMC_ITIC_MBAR.sh script for specified sigma and epsilons as two arrays by modifying the raw_par file.
RunGrid_name="RunGrid_CH3-s3.760e120.5-CH2-s3.980-4.020e53-63_select7_ref-all"

reference_foldernames_array="s3.700e123-s4.100e58 s3.725e123-s4.075e58 s3.750e123-s4.050e58 s3.775e123-s4.025e58 s3.800e123-s4.000e58 s3.825e123-s3.975e58 s3.850e123-s3.950e58 s3.875e123-s3.925e58 s3.900e123-s3.900e58"
Ncore="16"
Nsnapshots="1000"
raw_par="$HOME/Git/TranSFF/Forcefields/C4/C4_s3.760e120.5-sSOMEeSOME.par"
rerun_inp="none"                                                                                 # "none" or filename
GOMC_exe="$HOME/Git/GOMC/GOMC-FSHIFT2-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"
Selected_Ts="361.43 241.55 191.34 510.16 510.16 510.16 510.16"                                    # "all" or array
Selected_rhos="0.4873 0.6335 0.6822 0.0975 0.4873 0.6335 0.6822"                                  # "all" or array

sig=(3.980	3.984	3.988	3.992	3.996	4.000	4.004	4.008	4.012	4.016	4.020)
eps=(53.0	54.0	55.0	56.0	57.0	58.0	59.0	60.0	61.0	62.0	63.0)

# Plot_heatmap arguments
MW="58.1222"
true_data_file_array="$HOME/Git/TranSFF/Data/C4/REFPROP_select7.res"                                                               
true_data_label_array="REFPROP"
mbar_file_name_tail_keyword="target.res"
z_wt="0.5"
u_wt="0.5"
heatmap_outfilename_array="${z_wt}Z_${u_wt}U_REFPROP.grid"
sig_increment="0.002"
eps_increment="1"

if [ -e "$RunGrid_name" ]; then echo "$RunGrid_name folder already exists. Exiting..."; exit; fi

for isig in "${sig[@]}"
do
    for ieps in "${eps[@]}"
    do
        cp  $raw_par "s${isig}e${ieps}".par
        sed -i "s/some_sig/$isig/g" "s${isig}e${ieps}".par
        sed -i "s/some_eps/$ieps/g" "s${isig}e${ieps}".par
        bash $HOME/Git/TranSFF/Scripts/GOMC_ITIC_MBAR.sh "TFF" "$reference_foldernames_array" s${isig}e${ieps}.par $rerun_inp $Nsnapshots $Ncore $GOMC_exe "$Selected_Ts" "$Selected_rhos"
    done
done

rm -rf "${RunGrid_name}.parallel"
cat *.parallel >> "${RunGrid_name}.parallel"
parallel --jobs $Ncore < "${RunGrid_name}.parallel" > "${RunGrid_name}.log"

for isig in "${sig[@]}"
do
    for ieps in "${eps[@]}"
    do
        bash $HOME/Git/TranSFF/Scripts/GOMC_ITIC_MBAR.sh "FFT" "$reference_foldernames_array" s${isig}e${ieps}.par $rerun_inp $Nsnapshots $Ncore $GOMC_exe "$Selected_Ts" "$Selected_rhos"
    done
done

true_data_file_array=($true_data_file_array)
true_data_label_array=($true_data_label_array)
heatmap_outfilename_array=($heatmap_outfilename_array)
for i in $(seq 0 $((${#true_data_file_array[@]}-1)))
do 
    bash $HOME/Git/TranSFF/Scripts/Plot_heatmap.sh $MW ${true_data_file_array[i]} $mbar_file_name_tail_keyword $z_wt $u_wt ${heatmap_outfilename_array[i]} $sig_increment $eps_increment
    bash $HOME/Git/TranSFF/Scripts/Plot_zu.sh $MW ${true_data_file_array[i]} $mbar_file_name_tail_keyword ${true_data_label_array[i]}
done


mkdir $RunGrid_name 

cp $0 $RunGrid_name
for i in $(seq 0 $((${#true_data_file_array[@]}-1)))
do 
    mv ${heatmap_outfilename_array[i]} $RunGrid_name
    cp ${true_data_file_array[i]} $RunGrid_name
done
mv *.parallel $RunGrid_name
mv *.png $RunGrid_name 
mv *.res $RunGrid_name
mv *.log $RunGrid_name
mv *.par $RunGrid_name
if [ "$rerun_inp" != "none" ]; then mv $rerun_inp $RunGrid_name; fi