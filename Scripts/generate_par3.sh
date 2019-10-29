#!/bin/bash
# This script generates GOMC a par file from on a given string (e.g. 3.75-110.23-16-6_4.00-58.00-12-6) in current directory ("here" option) or in $HOME/Git/TranSFF/Forcefields directory ("there" option) 
# Syntax of the fourth argument: site types are separated by "_" and non-bonded parameters (nbp) are separated by "-". 
# If you need to have more nbp's just modify the first nested loop and assign a letter (nbp_char) for that nbp (e.g. if [ "$jPlusOne" == "4" ]; then nbp_char="m"; fi)
# Example: 
# bash $HOME/Git/TranSFF/Scripts/generate_par.sh "key" "C2" "there" "3.758652-110.23256_4.855-58.00" 2

keyword=$1          # "nokey" or any string
molec_name=$2
here_or_there=$3    # "here" or "there". "here" means generate the output in current directory, "there" means generate the output in Forcefields folder
sig_eps_nnn=$4      # E.g. 3.758-110.23_4.855-58.00 or 3.758-110.23-16.00_4.855-58.00-12.00 or 3.750-117.00
nnbp=$5             # Number of non-bonded parameters in the par file
raw_par=$6

Forcefileds_path="$HOME/Git/TranSFF/Forcefields/$molec_name"

if [ "$keyword" == "nokey" ]; then 
    keyword=""
else
    keyword="${keyword}_"
fi


sim_name=""
IFS='_' read -ra sig_eps_nnn_array <<< "$sig_eps_nnn"
for i in $(seq 0 $(echo "${#sig_eps_nnn_array[@]}-1" | bc)) 
do
    site_name=""
    IFS='-' read -ra sigepsnnn_array <<< "${sig_eps_nnn_array[i]}"
    for j in $(seq 0 $(echo "${#sigepsnnn_array[@]}-1" | bc)) 
    do
        iPlusOne=$((i+1))
        jPlusOne=$((j+1))

        if [ "$jPlusOne" == "1" ]; then nbp_char="s"; fi    # s stands for sigma
        if [ "$jPlusOne" == "2" ]; then nbp_char="e"; fi    # e stands for epsilon
        if [ "$jPlusOne" == "3" ]; then nbp_char="n"; fi    # n is the first exponent of LJ
        if [ "$jPlusOne" == "4" ]; then nbp_char="m"; fi    # m is the second exponent of LJ    (You can assign more letters to added nbp's)
        site_name="${site_name}-${nbp_char}${sigepsnnn_array[j]}"
    done
    site_name=${site_name:1}
    sim_name="${sim_name}_${site_name}"
done
sim_name="${sim_name:1}"

#if [ "$nnbp" == "2" ]; then
#    raw_par="${molec_name}_sSOMEeSOME.par"
#fi
#if [ "$nnbp" == "3" ]; then
#    raw_par="${molec_name}_sSOMEeSOMEnSOME.par"
#fi
raw_par_path="$Forcefileds_path/$raw_par"

par_file_name="${keyword}${molec_name}_${sim_name}.par"
if [ "$here_or_there" == "here" ]; then
    out_par_file_path="${PWD}/${par_file_name}"
elif [ "$here_or_there" == "there" ]; then
    out_par_file_path="${Forcefileds_path}/$par_file_name"
fi

cp  $raw_par_path $out_par_file_path

IFS='_' read -ra sig_eps_nnn_array <<< "$sig_eps_nnn"
for i in $(seq 0 $(echo "${#sig_eps_nnn_array[@]}-1" | bc)) 
do
    IFS='-' read -ra sigepsnnn_array <<< "${sig_eps_nnn_array[i]}"
    for j in $(seq 0 $(echo "${#sigepsnnn_array[@]}-1" | bc)) 
    do
        iPlusOne=$((i+1))
        jPlusOne=$((j+1))
        sed -i "s/some_nbp${jPlusOne}_site${iPlusOne}/${sigepsnnn_array[j]}/g" $out_par_file_path
    done
done
echo $sim_name $par_file_name