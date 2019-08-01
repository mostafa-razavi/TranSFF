#!/bin/bash
# This script runs GOMC_ITIC_MBAR.sh script for specified sigma and epsilons as two arrays by modifying the raw_par file.

raw_par="/home/mostafa/Git/TranSFF/Forcefields/C2_sSOMEeSOME.par"
Selected_Ts="259.42 137.97 360.00 360.00 360.00"
Selected_rhos="0.4286 0.6000 0.0857 0.4286 0.6000"
sig=(3.720 3.722 3.724 3.726 3.728 3.730 3.732 3.734 3.736 3.738 3.740)
eps=(114.5 115.0 115.5 116.0 116.5 117.0 117.5 118.0 118.5 119.0 119.5)

for isig in "${sig[@]}"
do
    for ieps in "${eps[@]}"
    do
        cp  $raw_par "s${isig}e${ieps}".par
        sed -i "s/some_sig/$isig/g" "s${isig}e${ieps}".par
        sed -i "s/some_eps/$ieps/g" "s${isig}e${ieps}".par
        bash ~/Git/TranSFF/Scripts/GOMC_ITIC_MBAR.sh 's3.650e117  s3.675e117  s3.700e117  s3.725e117  s3.750e117  s3.775e117  s3.800e117  s3.825e117  s3.850e117' s${isig}e${ieps}.par 1000 24 ~/Git/GOMC/GOMC-FSHIFT2-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT $Selected_Ts $Selected_rhos
    done
done
