#!/bin/bash
# This script runs GOMC_ITIC_MBAR.sh script for specified sigma and epsilons as two arrays by modifying the raw_par file.

reference_foldernames_array="s3.620e175 s3.645e175 s3.670e175 s3.695e175 s3.720e175 s3.745e175 s3.770e175 s3.795e175 s3.820e175"
Ncore="32"
Nsnapshots="1000"
raw_par="$HOME/Git/TranSFF/Forcefields/C1_sSOMEeSOME.par"
rerun_inp="r3.5.inp"                                                                    # "none" or filename
GOMC_exe="$HOME/Git/GOMC/GOMC-FSHIFT2-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"
Selected_Ts="167.20 95.90 228.00 228.00 228.00"                                        # "all" or array
Selected_rhos="0.3179 0.4450 0.0636 0.3179 0.4450"                                      # "all" or array
sig=(3.706 3.708 3.710 3.712 3.714 3.716 3.718 3.720 3.722 3.724 3.726 3.728 3.730 3.732 3.734 3.736)
eps=(161.5 162.0 162.5 163.0 163.5 164.0 164.5 165.0 165.5 166.0 166.5 167.0 167.5 168.0 168.5 169.0)
MW="16.04246"

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

bash $HOME/Git/TranSFF/Scripts/Plot_heatmap.sh $MW target.res GONvtRdr.res 0.5Z_0.5U_all.txt 0.5 0.5 0.002 1
bash $HOME/Git/TranSFF/Scripts/Plot_zu.sh $MW target.res GONvtRdr.res