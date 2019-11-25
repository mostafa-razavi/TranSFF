#!/bin/bash
# This script generates GOMC a par file from on a given string (e.g. CH3a-3.8-123-12_CH3b-3.8-120-12_CH2-4.0-58-12_CH1-4.7-13.5-12_CT-6.4-5-12) 
#   in current directory ("here" option) or in $HOME/Git/TranSFF/Forcefields/molec_name directory ("there" option) 
# Syntax of the fourth argument: site types are separated by "_" and non-bonded parameters (nbp) are separated by "-". First part is always the site name
# Note that the site_sig_eps_n could contain site types that do not exist in the molecule. This feature helps in simultaneous optimization of multiple molecules.
#   e.g, CT does not exists in IC5 molecule (see the following example)
#
# Example: 
# bash ~/Git/TranSFF/Scripts/generate_par4.sh key IC5 there CH3a-3.8-123-12_CH3b-3.8-120-12_CH2-4.0-58-12_CH1-4.7-13.5-12_CT-6.4-5-12 ~/Git/TranSFF/Forcefields/TranSFF0_Alkanes_SOME.par

keyword=$1              # "nokey" or any string. The keyword will be added to the beginning of the output file name
molec_name=$2
here_or_there=$3        # "here" or "there". "here" means generate the output in current directory, "there" means generate the output in Forcefields folder
site_sig_eps_n=$4       # E.g. CH3a-3.8-123-12_CH3b-3.8-120-12_CH2-4.0-58-12_CH1-4.7-13.5-12_CT-6.4-5-12
raw_par_path=$5         # The address of a par file that contains some_nbp2_{sitename} strings

if [ "$keyword" == "nokey" ]; then 
    keyword=""
else
    keyword="${keyword}_"
fi

sites_array=($(grep ATOM ~/Git/TranSFF/Molecules/$molec_name/$molec_name.top | awk '{print $3}'))

all_sites_string=""
IFS='_' read -ra site_sig_eps_n_array <<< "$site_sig_eps_n"
for i in $(seq 0 $(echo "${#site_sig_eps_n_array[@]}-1" | bc)) 
do
    site_string=""
    IFS='-' read -ra sitesigepsn_array <<< "${site_sig_eps_n_array[i]}"

    search_var="${sitesigepsn_array[0]}"
    for item in "${sites_array[@]}"; do
        if [ "$item" == "$search_var" ]; then 
            for j in $(seq 0 $(echo "${#sitesigepsn_array[@]}-1" | bc)) 
            do
                site_string="${site_string}-${sitesigepsn_array[j]}"
            done 
        site_string=${site_string:1}
        all_sites_string="${all_sites_string}_${site_string}"
        break
        fi
    done
done
all_sites_string="${all_sites_string:1}"

#par_file_name="${keyword}${molec_name}_${all_sites_string}.par"
par_file_name="${keyword}${all_sites_string}.par"

Forcefileds_path="$HOME/Git/TranSFF/Forcefields/$molec_name"
if [ "$here_or_there" == "here" ]; then
    out_par_file_path="${PWD}/${par_file_name}"
elif [ "$here_or_there" == "there" ]; then
    out_par_file_path="${Forcefileds_path}/$par_file_name"
fi
cp $raw_par_path $out_par_file_path


IFS='_' read -ra site_sig_eps_n_array <<< "$site_sig_eps_n"
for i in $(seq 0 $(echo "${#site_sig_eps_n_array[@]}-1" | bc)) 
do
    IFS='-' read -ra sitesigepsn_array <<< "${site_sig_eps_n_array[i]}"

    sed -i "s/some_nbp1_${sitesigepsn_array[0]}/${sitesigepsn_array[1]}/g" $out_par_file_path
    sed -i "s/some_nbp2_${sitesigepsn_array[0]}/${sitesigepsn_array[2]}/g" $out_par_file_path
    sed -i "s/some_nbp3_${sitesigepsn_array[0]}/${sitesigepsn_array[3]}/g" $out_par_file_path
done

echo $all_sites_string $par_file_name