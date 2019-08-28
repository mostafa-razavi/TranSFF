#!/bin/bash
# This script runs GOMC_ITIC_MBAR.sh script for specified sigma and epsilons as two arrays by modifying the raw_par file.
iteration_name=$1
sig=$2 
eps=$3 

reference_foldernames_array="s3.725e117 s3.750e117 s3.775e117"
Ncore="24"
Nsnapshots="1000"
raw_par="$HOME/Git/TranSFF/Forcefields/C2/C2_sSOMEeSOME.par"
rerun_inp="none"                                                                                 # "none" or filename
GOMC_exe="$HOME/Git/GOMC/GOMC-FSHIFT2-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"
Selected_Ts="259.42 174.46 137.97 360.00 360.00 360.00 360.00"                                    # "all" or array
Selected_rhos="0.4286 0.5571 0.6000 0.0857 0.4286 0.5571 0.6000"                                  # "all" or array

MW="30.06904"
true_data_file="$HOME/Git/TranSFF/Data/C2/REFPROP_select7.res" 
true_data_label="REFPROP"                                                              
z_wt="0.5"
u_wt="0.5"


if [ -e "$iteration_name" ]; then echo "$iteration_name folder already exists. Exiting..."; exit; fi

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

rm -rf "${iteration_name}.parallel"
cat *.parallel >> "${iteration_name}.parallel"
parallel --willcite --jobs $Ncore < "${iteration_name}.parallel" > "${iteration_name}.log"

for isig in "${sig[@]}"
do
    for ieps in "${eps[@]}"
    do 
        bash $HOME/Git/TranSFF/Scripts/GOMC_ITIC_MBAR.sh "FFT" "$reference_foldernames_array" s${isig}e${ieps}.par $rerun_inp $Nsnapshots $Ncore $GOMC_exe "$Selected_Ts" "$Selected_rhos"
    done
done


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