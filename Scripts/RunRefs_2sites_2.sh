#!/bin/bash
# This script runs RunITIC_GOMC_Parallel.sh script for specified sigma and epsilons (and nnn if needs be)

molecule="C12"
selected_itic_points="0.5336/547.99 0.6937/368.10 691.00/0.2135 691.00/0.5336 691.00/0.6937"
config_filename="FSHIFT_BULK_LONG.conf"
nnbp="2"
ncores="10"

OutputName="nvt" 
nblocks="5" 
true_data_file_name="REFPROP_select5.res"
true_data_file_label="REFPROP"
png_output="dsim.png"

sig_site1_array=(3.850 3.850 3.850 3.850 3.850 3.850 3.850 3.850)
sig_site2_array=(4.000 4.000 4.000 4.000 4.000 4.000 4.000 4.000)

eps_site1_array=(127.0 127.0 127.0 127.0 127.0 127.0 127.0 127.0 )
eps_site2_array=(56.0 57.0 58.0 59.0 61.0 62.0 63.0 64.0)

#nnn_site1_array=(12.0 12.0 12.0 12.0 12.0 12.0 12.0 12.0 )
#nnn_site2_array=(12.0 12.0 12.0 12.0 12.0 12.0 12.0 12.0 )

#=========================================================

CD=${PWD}
for i in $(seq 0 $(echo "${#sig_site1_array[@]}-1" | bc)) 
do
    
    if [ "$nnbp" == "2" ]; then
        sig_site1=${sig_site1_array[i]}
        eps_site1=${eps_site1_array[i]}
        sig_site2=${sig_site2_array[i]}
        eps_site2=${eps_site2_array[i]}
        sig_eps_nnn=${sig_site1}-${eps_site1}_${sig_site2}-${eps_site2}
    fi

    if [ "$nnbp" == "3" ]; then
        sig_site1=${sig_site1_array[i]}
        eps_site1=${eps_site1_array[i]}
        sig_site2=${sig_site2_array[i]}
        eps_site2=${eps_site2_array[i]}    
        nnn_site1=${nnn_site1_array[i]}
        nnn_site2=${nnn_site1_array[i]}        
        sig_eps_nnn=${sig_site1}-${eps_site1}-${nnn_site1}_${sig_site2}-${eps_site2}-${nnn_site2}
    fi    

    generate_par_output=$(bash $HOME/Git/TranSFF/Scripts/generate_par2.sh "nokey" "$molecule" "there" "$sig_eps_nnn" $nnbp)
    sim_name=$(echo $generate_par_output | awk '{print $1}')
    par_file_name=$(echo $generate_par_output | awk '{print $2}')
    
    mkdir $sim_name

    cd $CD/$sim_name
        cp $HOME/Git/TranSFF/Molecules/${molecule}/${molecule}_Files.zip .
        unzip ${molecule}_Files.zip
        rm ${molecule}_Files.zip     
        bash $HOME/Git/TranSFF/Scripts/RunITIC_GOMC_Parallel.sh $molecule $par_file_name $conf_file "$selected_itic_points" "no"
    cd $CD
done

rm -rf COMMANDS.parallel
bash $HOME/Git/nestplore/nestplore.sh 1 "cat COMMANDS.parallel" | tee COMMANDS.parallel

parallel --jobs $ncores < COMMANDS.parallel

for i in */
do
    cd $i
        bash ~/Git/TranSFF/Scripts/RunITIC_postprocess.sh $molecule $config_filename $OutputName $nblocks $true_data_file_name $true_data_file_label $png_output
    cd ..
done
