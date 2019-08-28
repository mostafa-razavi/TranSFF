#!/bin/bash
# This script runs GOMC_ITIC_MBAR.sh script for specified sigma and epsilons as two arrays by modifying the raw_par file.

molec_name="IB"
sig_site1=(3.700	3.725	3.750	3.775	3.800	3.825	3.850	3.875	3.900)
sig_site2=(4.800	4.775	4.750	4.725	4.700	4.675	4.650	4.625	4.600)

eps_site1="120"
eps_site2="13.5"

Scripts_path="$HOME/Git/TranSFF/Scripts"
Molecules_path="$HOME/Git/TranSFF/Molecules/$molec_name"
Forcefileds_path="$HOME/Git/TranSFF/Forcefields/$molec_name"

raw_par="${molec_name}_sSOMEeSOME.par"
raw_par_path="$Forcefileds_path/$raw_par"
conf_file="FSHIFT_BULK_LONG.conf"

i=-1
for isig_site1 in "${sig_site1[@]}"
do
    i=$((i+1))
    isig_site2=${sig_site2[i]}

    sim_name="s${isig_site1}e${eps_site1}-s${isig_site2}e${eps_site2}"
    par_file_name="${molec_name}_${sim_name}.par"
    par_file_path="${Forcefileds_path}/$par_file_name"

    cp  $raw_par_path $par_file_path

    sed -i "s/some_sig_site1/$isig_site1/g" $par_file_path
    sed -i "s/some_sig_site2/$isig_site2/g" $par_file_path

    sed -i "s/some_eps_site1/$eps_site1/g" $par_file_path
    sed -i "s/some_eps_site2/$eps_site2/g" $par_file_path
            
    mkdir $sim_name
    cd $sim_name
    bash ${Scripts_path}/RunITIC_GOMC_Parallel.sh $molec_name $par_file_name $conf_file "no"
    cd ..
done