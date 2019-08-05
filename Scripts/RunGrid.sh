#!/bin/bash
# This script runs GOMC_ITIC_MBAR.sh script for specified sigma and epsilons as two arrays by modifying the raw_par file.

reference_foldernames_array="s3.620e175 s3.645e175 s3.670e175 s3.695e175 s3.720e175 s3.745e175 s3.770e175 s3.795e175 s3.820e175"
Ncore="32"
Nsnapshots="1000"
raw_par="$HOME/Git/TranSFF/Forcefields/C1_sSOMEeSOME.par"
rerun_inp="r3.0.inp"                                                                    # "none" or filename
GOMC_exe="$HOME/Git/GOMC/GOMC-FSHIFT2-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"
Selected_Ts="167.20 95.90 228.00 228.00 228.00"                                        # "all" or array
Selected_rhos="0.3179 0.4450 0.0636 0.3179 0.4450"                                      # "all" or array
sig=(3.706 3.708 3.710 3.712 3.714 3.716 3.718 3.720 3.722 3.724 3.726 3.728 3.730 3.732 3.734 3.736)
eps=(171.5 172.0 172.5 173.0 173.5 174.0 174.5 175.0 175.5 176.0 176.5 177.0 177.5 178.0 178.5 179.0)

for isig in "${sig[@]}"
do
    for ieps in "${eps[@]}"
    do
        cp  $raw_par "s${isig}e${ieps}".par
        sed -i "s/some_sig/$isig/g" "s${isig}e${ieps}".par
        sed -i "s/some_eps/$ieps/g" "s${isig}e${ieps}".par
        bash $HOME/Git/TranSFF/Scripts/GOMC_ITIC_MBAR.sh "$reference_foldernames_array" s${isig}e${ieps}.par $rerun_inp $Nsnapshots $Ncore $GOMC_exe "$Selected_Ts" "$Selected_rhos"
    done
done
