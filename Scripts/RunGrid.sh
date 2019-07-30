#!/bin/bash
# This script runs GOMC_ITIC_MBAR.sh script for specified sigma and epsilons as two arrays by modifying the raw_par file.
raw_par="/home/mostafa/Git/TranSFF/Forcefields/C2_sSOMEeSOME.par"
sig=(3.730 3.740 3.750 3.760 3.770)
eps=(109 113 117 121 125)
for isig in "${sig[@]}"
do
    for ieps in "${eps[@]}"
    do

    cp  $raw_par "s${isig}e${ieps}".par
    sed -i "s/some_sig/$isig/g" "s${isig}e${ieps}".par
    sed -i "s/some_eps/$ieps/g" "s${isig}e${ieps}".par
    bash ~/Git/TranSFF/Scripts/GOMC_ITIC_MBAR.sh 's3.650e117  s3.675e117  s3.700e117  s3.725e117  s3.750e117  s3.775e117  s3.800e117  s3.825e117  s3.850e117' s${isig}e${ieps}.par 1000 24 ~/Git/GOMC/GOMC-FSHIFT2-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT

    done
done
