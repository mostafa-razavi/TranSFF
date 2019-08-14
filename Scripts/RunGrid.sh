#!/bin/bash
# This script runs GOMC_ITIC_MBAR.sh script for specified sigma and epsilons as two arrays by modifying the raw_par file.
RunGrid_name="RunGrid_sig3.740-3.770_eps116.5-124_lines-1-2-8-10-19-23-26-27_ref-s3.725e117-s3.750e117-s3.775e117"
reference_foldernames_array="s3.725e117 s3.750e117 s3.775e117"
Ncore="24"
Nsnapshots="1000"
raw_par="$HOME/Git/TranSFF/Forcefields/C2_sSOMEeSOME.par"
rerun_inp="none"     
true_data_file="REFPROP.res"                                                               # "none" or filename
GOMC_exe="$HOME/Git/GOMC/GOMC-FSHIFT2-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"
Selected_Ts="259.42 174.46 137.97 360.00 360.00 360.00 360.00"                                    # "all" or array
Selected_rhos="0.4286 0.5571 0.6000 0.0857 0.4286 0.5571 0.6000"                                  # "all" or array
sig=(3.740 3.742 3.744 3.746 3.748 3.750 3.752 3.754 3.756 3.758 3.760 3.762 3.764 3.766 3.768 3.770)
eps=(116.5 117.0 117.5 118.0 118.5 119.0 119.5 120.0 120.5 121.0 121.5 122.0 122.5 123.0 123.5 124.0)
MW="30.06904"

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

bash $HOME/Git/TranSFF/Scripts/Plot_heatmap.sh $MW target.res $true_data_file "TraPPE-UA" 0.5Z_0.5U_all.txt 0.5 0.5 0.002 1
bash $HOME/Git/TranSFF/Scripts/Plot_zu.sh $MW target.res $true_data_file "TraPPE-UA"

mkdir $RunGrid_name 

cp $0 $RunGrid_name 2>/dev/null
mv 0.5Z_0.5U_all.txt $RunGrid_name
mv $true_data_file $RunGrid_name
mv *.parallel $RunGrid_name
mv *.png $RunGrid_name 2>/dev/null
mv *.res $RunGrid_name
mv *.log $RunGrid_name
mv *.par $RunGrid_name
mv *.inp $RunGrid_name 2>/dev/null