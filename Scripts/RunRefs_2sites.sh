#!/bin/bash
# This script runs GOMC_ITIC_MBAR.sh script for specified sigma and epsilons as two arrays by modifying the raw_par file.

molec_name="C12"
sig_ch3=(3.700	3.725	3.750	3.775	3.800	3.825	3.850	3.875	3.900)
sig_ch2=(4.100	4.075	4.050	4.025	4.000	3.975	3.950	3.925	3.900)

eps_ch3="123"
eps_ch2="58"

Scripts_path="$HOME/Git/TranSFF/Scripts"
Molecules_path="$HOME/Git/TranSFF/Molecules/$molec_name"
Forcefileds_path="$HOME/Git/TranSFF/Forcefields"

raw_par="${molec_name}_sSOMEeSOME.par"
raw_par_path="$Forcefileds_path/$raw_par"

i=-1
for isig_ch3 in "${sig_ch3[@]}"
do
    i=$((i+1))
    isig_ch2=${sig_ch2[i]}

    sim_name="s${isig_ch3}e${eps_ch3}-s${isig_ch2}e${eps_ch2}"
    par_file_name="${molec_name}_${sim_name}.par"
    par_file_path="${Forcefileds_path}/$par_file_name"

    cp  $raw_par_path $par_file_path

    sed -i "s/some_sig_ch3/$isig_ch3/g" $par_file_path
    sed -i "s/some_sig_ch2/$isig_ch2/g" $par_file_path

    sed -i "s/some_eps_ch3/$eps_ch3/g" $par_file_path
    sed -i "s/some_eps_ch2/$eps_ch2/g" $par_file_path
            
    mkdir $sim_name
    cd $sim_name
    bash ${Scripts_path}/RunITIC_GOMC_Parallel.sh prepare $par_file_name
    cd ..
done