#!/bin/bash
# This script runs GOMC_ITIC_MBAR.sh script for specified sigma and epsilons as two arrays by modifying the raw_par file.
raw_par="/home/mostafa/Git/TranSFF/Forcefields/C2_sSOMEeSOME.par"
Selected_Ts="360.00 235.02"
Selected_rhos="0.6000 0.5571"
sig=(3.730)
eps=(109)
for isig in "${sig[@]}"
do
    for ieps in "${eps[@]}"
    do

    cp  $raw_par "s${isig}e${ieps}".par
    sed -i "s/some_sig/$isig/g" "s${isig}e${ieps}".par
    sed -i "s/some_eps/$ieps/g" "s${isig}e${ieps}".par
    bash ~/Git/TranSFF/Scripts/GOMC_ITIC_MBAR.sh 's3.650e117  s3.675e117  s3.700e117  s3.725e117  s3.750e117  s3.775e117  s3.800e117  s3.825e117  s3.850e117' s${isig}e${ieps}.par 1000 24 ~/Git/GOMC/GOMC-FSHIFT2-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT "$Selected_Ts" "$Selected_rhos"

    done
done
