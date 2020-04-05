keyword=$1
molecule=$2
selected_itic_points=$3
Nproc=$4
sig_eps_nnn=$5
reference_foldernames_array=$6
true_data_file=$7
true_data_label=$8
raw_par_path=$9
GOMC_exe=${10}
weights_file=${11}
Nsnapshots=${12}
rerun_inp=${13}

generate_par_output=$(bash $HOME/Git/TranSFF/Scripts/generate_par4.sh "nokey" "${molecule}" "here" "${sig_eps_nnn}" "$raw_par_path")

sim_name=$(echo $generate_par_output | awk '{print $1}')
par_file_name=$(echo $generate_par_output | awk '{print $2}')

echo $par_file_name $sig_eps_nnn
echo

MW=$(grep "MW:" $HOME/Git/TranSFF/Molecules/${molecule}/${molecule}.itic | awk '{print $2}')


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


bash $HOME/Git/TranSFF/Scripts/GOMC_ITIC_MBAR_3.sh "FFT" "$keyword" "$reference_foldernames_array" $par_file_name $rerun_inp $Nsnapshots $Nproc $GOMC_exe "$Selected_Ts" "$Selected_rhos" "$ures_or_pures"

mbar_data_file=$(ls "${keyword}"*".target.res")
#score=$(python3.6 $HOME/Git/TranSFF/Scripts/calc_mbar_from_true_data_dev_rmsd.py $MW ${true_data_file} $mbar_data_file $z_wt $u_wt $n_wt $number_of_lowest_Neff $target_Neff)
score=$(python3.6 $HOME/Git/TranSFF/Scripts/calc_mbar_from_true_data_dev_rmsd_weighted.py $MW ${true_data_file} $mbar_data_file $weights_file)
echo $score > ${keyword}.score

if [ -e "$HOME/Git/TranSFF/Data/${molecule}/${true_data_label}.res" ]; then # We want to plot as many true data as possible
    plot_true_data="$HOME/Git/TranSFF/Data/${molecule}/${true_data_label}.res"
else
    plot_true_data="$true_data_file"
fi

python3.6 $HOME/Git/TranSFF/Scripts/plot_mbar_vs_true_data_2.py $MW "${plot_true_data}" $mbar_data_file ${true_data_label} ${mbar_data_file}.png

python3.6 $HOME/Git/TranSFF/Scripts/GOMC_MBAR_res_to_trhozures.py $MW $mbar_data_file "${keyword}.trhozures.res"

rm -rf "${keyword}_${sig_eps_nnn}"
mkdir "${keyword}_${sig_eps_nnn}" 

mv "${keyword}"*".parallel" "${keyword}_${sig_eps_nnn}"
mv "${keyword}"*".res" "${keyword}_${sig_eps_nnn}"
#mv "${keyword}"*".log" "${keyword}_${sig_eps_nnn}"
#mv "${keyword}"*".par" "${keyword}_${sig_eps_nnn}"
cp $par_file_name "${keyword}_${sig_eps_nnn}"
mv "${keyword}"*".score" "${keyword}_${sig_eps_nnn}"
mv "${keyword}"*".png" "${keyword}_${sig_eps_nnn}"
if [ "$rerun_inp" != "none" ]; then mv $rerun_inp "${keyword}_${sig_eps_nnn}"; fi