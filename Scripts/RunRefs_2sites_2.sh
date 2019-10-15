#!/bin/bash
# This script runs RunITIC_GOMC_Parallel.sh script for specified sigma and epsilons

molecule="C12"
selected_itic_points="0.5336/547.99 0.6937/368.10 691.00/0.2135 691.00/0.5336 691.00/0.6937"
conf_file="FSHIFT_BULK_LONG.conf"
nnbp="3"
isRun="no"

sig_site1=(3.850 3.850 3.850 3.850 3.850 3.850 3.850 3.850)
sig_site2=(4.000 4.000 4.000 4.000 4.000 4.000 4.000 4.000)

eps_site1=(127.0 127.0 127.0 127.0 127.0 127.0 127.0 127.0 )
eps_site2=(56.0 57.0 58.0 59.0 61.0 62.0 63.0 64.0)

nnn_site1=(12.0 12.0 12.0 12.0 12.0 12.0 12.0 12.0 )
nnn_site2=(12.0 12.0 12.0 12.0 12.0 12.0 12.0 12.0 )

#=========================================================

CD=${PWD}
for i in $(seq 0 $(echo "${#sig_site1[@]}-1" | bc)) 
do
    
    if [ "$nnbp" == 2]; then
        sig_site1=${sig_site1[i]}
        eps_site1=${eps_site1[i]}
        sig_site2=${sig_site2[i]}
        eps_site2=${eps_site2[i]}
        sig_eps_nnn=${sig_site1}-${eps_site1}_${sig_site2}-${eps_site2}
    fi

    if [ "$nnbp" == 3]; then
        sig_site1=${sig_site1[i]}
        eps_site1=${eps_site1[i]}
        sig_site2=${sig_site2[i]}
        eps_site2=${eps_site2[i]}    
        sig_eps_nnn=${sig_site1}-${eps_site1}_${sig_site2}-${eps_site2}
    fi    

    generate_par_output=$(bash $HOME/Git/TranSFF/Scripts/generate_par.sh "nokey" "$molecule" "here" "$sig_eps_nnn")
    sim_name=$(echo $generate_par_output | awk '{print $1}')
    par_file_name=$(echo $generate_par_output | awk '{print $2}')
    
    mkdir $sim_name

    cd $CD/$sim_name
        cp $HOME/Git/TranSFF/Molecules/${molecule}/${molecule}_Files.zip .
        unzip ${molecule}_Files.zip
        rm ${molecule}_Files.zip     
        mv $CD/$par_file_name $CD/$sim_name/Files
        bash $HOME/Git/TranSFF/Scripts/RunITIC_GOMC_Parallel.sh $molecule $par_file_name $conf_file "$selected_itic_points" "$isRun"
    cd $CD
done