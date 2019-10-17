#!bin/bash
molecule=$1
nnbp=$2
reference_folder=$3
prediction_folder=$4
selected_itic_points=$5

sig_eps_nnn=$(echo $prediction_folder | sed "s/-/_/g")
sig_eps_nnn=$(echo $sig_eps_nnn | sed "s/s//g")
sig_eps_nnn=$(echo $sig_eps_nnn | sed "s/e/-/g")


generate_par_output=$(bash $HOME/Git/TranSFF/Scripts/generate_par2.sh "nokey" "$molecule" "here" "$sig_eps_nnn" $nnbp)
sim_name=$(echo $generate_par_output | awk '{print $1}')
par_file_name=$(echo $generate_par_output | awk '{print $2}')
mv $par_file_name ${molecule}_$prediction_folder.par
keyword="N1000_MBAR_${prediction_folder}"

MW=$(grep "MW:" $HOME/Git/TranSFF/Molecules/${molecule}/${molecule}.itic | awk '{print $2}')
bash $HOME/Git/TranSFF/Scripts/ReRunITIC_GOMC_Parallel.sh "${keyword}" ${molecule} "$selected_itic_points" ${molecule}_${prediction_folder}.par FSHIFT_BULK_2M.conf 5 ${reference_folder} $HOME/Git/TranSFF/Data/${molecule}/REFPROP_select5.res REFPROP

python3.6 $HOME/Git/TranSFF/Scripts/plot_mbar_vs_true_data_2.py ${MW} $HOME/Git/TranSFF/Data/${molecule}/REFPROP_select5.res "${keyword}"/"${keyword}".target.res REFPROP Comparison_${prediction_folder}.png ${prediction_folder}/trhozures.res
mv Comparison_${prediction_folder}.png "${keyword}"
rm -rf ${molecule}_$prediction_folder.par