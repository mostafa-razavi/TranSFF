#!/bin/bash
# This script runs GOMC_ITIC_MBAR.sh script for specified sigma and epsilons as two arrays by modifying the raw_par file.

RunGrid_name="RunGrid_sig3.740-3.770_eps116.5-124_lines-1-2-8-10-19-23-26-27_ref-s3.725e117-s3.750e117-s3.775e117"
reference_foldernames_array="s3.725e117"
Ncore="24"
Nsnapshots="1000"
raw_par="$HOME/Git/TranSFF/Forcefields/C2_sSOMEeSOME.par"
rerun_inp="none"                                                                                 # "none" or filename
GOMC_exe="$HOME/Git/GOMC/GOMC-FSHIFT2-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"
Selected_Ts="259.42 174.46 137.97 360.00 360.00 360.00 360.00"                                    # "all" or array
Selected_rhos="0.4286 0.5571 0.6000 0.0857 0.4286 0.5571 0.6000"                                  # "all" or array
sig=(3.740 3.742)
eps=(116.5 117.0)

# Plot_heatmap arguments
MW="30.06904"
true_data_file_array="$HOME/Git/TranSFF/Data/C2/GONvtRdr_select7.res $HOME/Git/TranSFF/Data/C2/REFPROP_select7.res"                                                               
true_data_label="TraPPE-UA"
mbar_file_name_tail_keyword="target.res"
z_wt="0.5"
u_wt="0.5"
heatmap_outfile="${z_wt}Z_${u_wt}U.grid"
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
for i in $(seq 0 $((${#true_data_file_array[@]}-1)))
do 
echo ${true_data_file_array[i]}
    bash $HOME/Git/TranSFF/Scripts/Plot_heatmap.sh $MW ${true_data_file_array[i]} $mbar_file_name_tail_keyword $z_wt $u_wt $heatmap_outfile $sig_increment $eps_increment
    bash $HOME/Git/TranSFF/Scripts/Plot_zu.sh $MW ${true_data_file_array[i]} $mbar_file_name_tail_keyword $true_data_label
done


mkdir $RunGrid_name 

cp $0 $RunGrid_name
mv $heatmap_outfile $RunGrid_name
for i in $(seq 0 $((${#true_data_file_array[@]}-1))); do cp $true_data_file $RunGrid_name; done
mv *.parallel $RunGrid_name
mv *.png $RunGrid_name 
mv *.res $RunGrid_name
mv *.log $RunGrid_name
mv *.par $RunGrid_name
if [ "$rerun_inp" != "none" ]; then mv $rerun_inp $RunGrid_name; fi