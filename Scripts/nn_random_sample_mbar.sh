#!/bin/bash
CD=${PWD}
gomc_exe_address="$HOME/Git/GOMC/GOMC-FSHIFT2-SWF-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"
raw_par="23DMB_TranSFF_sSOMEeSOME.par"
sig_eps_nnn_array="paste here list of parameter sets"

sig_eps_nnn_array=($sig_eps_nnn_array)

ref_array="3.500-100.00_4.400-40.00"
config_filename="FSHIFT_6M.conf"
Nproc="9"
molec="23DMB"

molecules_array=($molecules_array)

select_itic_points=$(cat $HOME/Git/TranSFF/Molecules/${molec}/${molec}_select9.trho)

i=0
big_array_len_over_two=$(echo "${#sig_eps_nnn_array[@]}-1" | bc)

for i in $(seq 1270 4 $big_array_len_over_two)
do
    
    key="Sample${i}_${sig_eps_nnn_array[i]}"
    bash ~/Git/TranSFF/Scripts/run_particle.sh $key ${molec} "$select_itic_points" $config_filename $Nproc "${sig_eps_nnn_array[i]}" "$ref_array"  $HOME/Git/TranSFF/Data/${molec}/TranSFF0_select9.res TranSFF0 $raw_par $gomc_exe_address &

    k=$((i+1))
    key="Sample${k}_${sig_eps_nnn_array[i+1]}"
    bash ~/Git/TranSFF/Scripts/run_particle.sh $key ${molec} "$select_itic_points" $config_filename $Nproc "${sig_eps_nnn_array[i+1]}" "$ref_array"  $HOME/Git/TranSFF/Data/${molec}/TranSFF0_select9.res TranSFF0 $raw_par $gomc_exe_address &

    k=$((i+2))
    key="Sample${k}_${sig_eps_nnn_array[i+2]}"
    bash ~/Git/TranSFF/Scripts/run_particle.sh $key ${molec} "$select_itic_points" $config_filename $Nproc "${sig_eps_nnn_array[i+2]}" "$ref_array"  $HOME/Git/TranSFF/Data/${molec}/TranSFF0_select9.res TranSFF0 $raw_par $gomc_exe_address &

    k=$((i+3))
    key="Sample${k}_${sig_eps_nnn_array[i+3]}"
    bash ~/Git/TranSFF/Scripts/run_particle.sh $key ${molec} "$select_itic_points" $config_filename $Nproc "${sig_eps_nnn_array[i+3]}" "$ref_array"  $HOME/Git/TranSFF/Data/${molec}/TranSFF0_select9.res TranSFF0 $raw_par $gomc_exe_address &    

    wait
done
