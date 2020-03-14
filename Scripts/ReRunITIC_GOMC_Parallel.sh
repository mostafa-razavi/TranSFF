#!/bin/bash
# This script runs GOMC_ITIC_MBAR_2.sh, calc_mbar_from_true_data_dev_dev.py, and plot_mbar_vs_true_data_2 scripts and puts everything in keyword folder
# Example:
# bash ReRunITIC_GOMC_Parallel.sh some_keyword C12 "0.5336/547.99 0.6937/368.10 691.00/0.2135 691.00/0.5336 691.00/0.6937" C12_s3.780e120.0_s4.00e60.0.par FSHIFT_BULK_2M.conf 5 C12_s3.760e120.0_s4.00e60.0 ~/Git/TranSFF/Data/C12/REFPROP_select5.res REFPROP

#===== Argument Parameters =====
keyword=$1          # Name of the folder to put everything at the end.
molecule=$2
selected_itic_points=$3
par_file_name=$4
config_filename=$5
Nproc=$6
reference_foldernames_array=$7
true_data_file=$8 
true_data_label=$9                                                               
gomc_exe_address=${10}


Nsnapshots="1000"
rerun_inp="none"                                                                                 # "none" or filename
MW=$(grep "MW:" $HOME/Git/TranSFF/Molecules/${molecule}/${molecule}.itic | awk '{print $2}')
z_wt="0.50"
u_wt="0.40"
n_wt="0.10"
number_of_lowest_Neff="1"
target_Neff="50"

if [ "$(echo "$z_wt" | bc)" == 0 ]; then
    ures_or_pures="ures"
else
    ures_or_pures="p_ures"
fi

# Separate Trho pair array into T array and rho array
Selected_Ts=""
Selected_rhos=""
selected_itic_points=($selected_itic_points)

for iRhoOrT in $(seq 0 $(echo "${#selected_itic_points[@]}-1" | bc))	# Loop from 0 to len(Selected_rhos)-1
do
    IFS='/' read -ra element <<< "${selected_itic_points[iRhoOrT]}"
    rho_or_T1=${element[0]}
    rho_or_T2=${element[1]}
    if (( $(echo "$rho_or_T1 < 5" | bc -l) )); then # 5 is just a number too high for density and too low for temperature
        rho=$rho_or_T1
        T=$rho_or_T2
        pair="$rho/$T"
    else
        rho=$rho_or_T2
        T=$rho_or_T1
        pair="$T/$rho"
    fi    

    Selected_Ts="${Selected_Ts} $T"
    Selected_rhos="${Selected_rhos} $rho"
done

bash $HOME/Git/TranSFF/Scripts/GOMC_ITIC_MBAR_3.sh "TFF" "$keyword" "$reference_foldernames_array" $par_file_name $rerun_inp $Nsnapshots $Nproc $gomc_exe_address "$Selected_Ts" "$Selected_rhos" "$ures_or_pures"

rm -rf "${keyword}.parallel"
cat "${keyword}"*".parallel" >> "${keyword}.parallel"
parallel --willcite --jobs $Nproc < "${keyword}.parallel" #> "${keyword}.log"

bash $HOME/Git/TranSFF/Scripts/GOMC_ITIC_MBAR_3.sh "FFT" "$keyword" "$reference_foldernames_array" $par_file_name $rerun_inp $Nsnapshots $Nproc $gomc_exe_address "$Selected_Ts" "$Selected_rhos" "$ures_or_pures"

mbar_data_file=$(ls "${keyword}"*".target.res")
score=$(python3.6 $HOME/Git/TranSFF/Scripts/calc_mbar_from_true_data_dev_rmsd.py $MW ${true_data_file} $mbar_data_file $z_wt $u_wt $n_wt $number_of_lowest_Neff $target_Neff)
echo $score > ${keyword}.score
python3.6 $HOME/Git/TranSFF/Scripts/plot_mbar_vs_true_data_2.py $MW ${true_data_file} $mbar_data_file ${true_data_label} ${mbar_data_file}.png

python3.6 $HOME/Git/TranSFF/Scripts/GOMC_MBAR_res_to_trhozures.py $MW $mbar_data_file "${keyword}.trhozures.res"

rm -rf $keyword 
mkdir $keyword 

mv "${keyword}"*".parallel" $keyword
mv "${keyword}"*".res" $keyword
#mv "${keyword}"*".log" $keyword
mv "${keyword}"*".par" $keyword
mv "${keyword}"*".score" $keyword
mv "${keyword}"*".png" $keyword
if [ "$rerun_inp" != "none" ]; then mv $rerun_inp $keyword; fi