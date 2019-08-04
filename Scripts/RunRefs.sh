#!/bin/bash
# This script runs GOMC_ITIC_MBAR.sh script for specified sigma and epsilons as two arrays by modifying the raw_par file.

#===== Important paths =====
Scripts_path="$HOME/Git/TranSFF/Scripts"
Molecules_path="$HOME/Git/TranSFF/Molecules/$molec_name"
Forcefileds_path="$HOME/Git/TranSFF/Forcefields"

raw_par="C1_sSOMEeSOME.par"
raw_par_path="$Forcefileds_path/$raw_par"
sig=(3.620 3.645 3.670 3.695 3.720 3.745 3.770 3.795 3.820)
eps=(175)

for isig in "${sig[@]}"
do
    for ieps in "${eps[@]}"
    do
        cp  $raw_par_path "${Forcefileds_path}/C1_s${isig}e${ieps}.par"
        sed -i "s/some_sig/$isig/g" "${Forcefileds_path}/C1_s${isig}e${ieps}.par"
        sed -i "s/some_eps/$ieps/g" "${Forcefileds_path}/C1_s${isig}e${ieps}.par"

        mkdir s${isig}e${ieps}
        cd s${isig}e${ieps}
        bash ${Scripts_path}/RunITIC_GOMC_Parallel.sh prepare "C1_s${isig}e${ieps}.par"
        cd ..
    done
done