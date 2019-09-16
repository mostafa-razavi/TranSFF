#!/bin/bash
# This script runs GOMC_ITIC_MBAR_2.sh script using 

#===== Argument Parameters =====
keyword=$1
molecule=$2
selected_itic_points=$3
par_file_name=$4
config_filename=$5
Nproc=$6
reference_foldernames_array=$7


Nsnapshots="1000"
rerun_inp="none"                                                                                 # "none" or filename
GOMC_exe="$HOME/Git/GOMC/GOMC-FSHIFT2-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"
MW="30.06904"
true_data_file="$HOME/Git/TranSFF/Data/C2/REFPROP_select7.res" 
true_data_label="REFPROP"                                                              
z_wt="1.0"
u_wt="0.0"

# Separate Trho pair array into T array and rho array
Selected_Ts=""
Selected_rhos=""
selected_itic_points=($selected_itic_points)

for iRhoOrT in $(seq 0 $(echo "${#selected_itic_points[@]}-1" | bc))	# Loop from 0 to len(Selected_rhos)-1
do
    IFS='/' read -ra element <<< "${selected_itic_points[iRhoOrT]}"
    rho_or_T1=${element[0]}
    rho_or_T2=${element[1]}
    if (( $(echo "$rho_or_T1 > 5" | bc -l) )); then # % is just a number too high for density and too low for temperature
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
Selected_Ts=($Selected_Ts)
Selected_rhos=($Selected_rhos)


bash $HOME/Git/TranSFF/Scripts/GOMC_ITIC_MBAR_2.sh "TFF" "$keyword" "$reference_foldernames_array" $par_file_name $rerun_inp $Nsnapshots $Nproc $GOMC_exe "$Selected_Ts" "$Selected_rhos"

rm -rf "${keyword}.parallel"
cat "${keyword}*.parallel" >> "${keyword}.parallel"
parallel --willcite --jobs $Nproc < "${keyword}.parallel" > "${keyword}.log"
 
bash $HOME/Git/TranSFF/Scripts/GOMC_ITIC_MBAR_2.sh "FFT" "$keyword" "$reference_foldernames_array" $par_file_name $rerun_inp $Nsnapshots $Nproc $GOMC_exe "$Selected_Ts" "$Selected_rhos"

mbar_data_file=$(ls "${keyword}*.target.res")
score=$(python3.6 $HOME/Git/TranSFF/Scripts/calc_mbar_from_true_data_dev.py $MW ${true_data_file} $mbar_data_file $z_wt $u_wt)
echo $score > ${keyword}.score
python3.6 $HOME/Git/TranSFF/Scripts/plot_mbar_vs_true_data.py $MW ${true_data_file} $mbar_data_file ${true_data_label} ${mbar_data_file}.png

mkdir $keyword 

mv "${keyword}*.parallel" $keyword
mv "${keyword}*.res" $keyword
mv "${keyword}*.log" $keyword
mv "${keyword}*.par" $keyword
mv "${keyword}*.score" $keyword
mv "${keyword}*.png" $keyword
if [ "$rerun_inp" != "none" ]; then mv $rerun_inp $keyword; fi