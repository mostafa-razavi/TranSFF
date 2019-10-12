#!/bin/bash
# This script runs GOMC_ITIC_MBAR.sh script for specified sigma and epsilons as two arrays by modifying the raw_par file.

molecule="C12"
sig_site1=(3.850    3.850   3.850   3.850   3.850   3.850   3.850   3.850   3.850)
sig_site2=(3.920	3.940	3.960	3.980	4.000	4.020	4.040	4.060	4.080)
selected_itic_points="0.5336/547.99 0.6937/368.10 691.00/0.2135 691.00/0.5336 691.00/0.6937"

eps_site1="127"
eps_site2="60"

Scripts_path="$HOME/Git/TranSFF/Scripts"
Molecules_path="$HOME/Git/TranSFF/Molecules/$molecule"
Forcefileds_path="$HOME/Git/TranSFF/Forcefields/$molecule"

raw_par="${molecule}_sSOMEeSOME2.par"
raw_par_path="$Forcefileds_path/$raw_par"
conf_file="FSHIFT_BULK_LONG.conf"


i=-1
for isig_site1 in "${sig_site1[@]}"
do
    i=$((i+1))
    isig_site2=${sig_site2[i]}

    sim_name="s${isig_site1}e${eps_site1}-s${isig_site2}e${eps_site2}"
    par_file_name="${molecule}_${sim_name}.par"
    par_file_path="${Forcefileds_path}/$par_file_name"

    cp  $raw_par_path $par_file_path

    sed -i "s/some_sig_site1/$isig_site1/g" $par_file_path
    sed -i "s/some_sig_site2/$isig_site2/g" $par_file_path

    sed -i "s/some_eps_site1/$eps_site1/g" $par_file_path
    sed -i "s/some_eps_site2/$eps_site2/g" $par_file_path
            
    mkdir $sim_name
    cd $sim_name
        cp $HOME/Git/TranSFF/Molecules/${molecule}/${molecule}_Files.zip .
        unzip ${molecule}_Files.zip
        rm ${molecule}_Files.zip     
        bash ${Scripts_path}/RunITIC_GOMC_Parallel.sh $molecule $par_file_name $conf_file "$selected_itic_points" "no"
    cd ..
done