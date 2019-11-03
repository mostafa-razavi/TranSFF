#!/bin/bash
CD=${PWD}

molecules_array="C4 C8 C12"
ref_array="3.78-120_4.01-60	3.82-126_3.99-56 3.76-120_4.02-60 3.84-126_3.98-56 3.78-126_3.99-60 3.82-120_4.01-56 3.76-126_4.02-56 3.84-120_3.98-60"
config_filename="FSHIFT_BULK_2M.conf"
Nproc=$(nproc)
gomc_exe_address="$HOME/Git/GOMC/GOMC-FSHIFT2-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"


rm -rf ${CD}/COMMANDS.parallel
molecules_array=($molecules_array)
ref_array=($ref_array)
for molec in "${molecules_array[@]}"
do 
    mkdir ${CD}/${molec}

    for ref in "${ref_array[@]}"
    do
        mkdir ${CD}/${molec}/$ref
        cd ${CD}/${molec}/$ref

        cp $HOME/Git/TranSFF/Molecules/${molec}/${molec}_Files.zip ${CD}/${molec}/$ref
        unzip ${molec}_Files.zip
        rm ${molec}_Files.zip

        raw_par="${molec}_TranSFF_sSOMEeSOME.par"
        generate_par_output=$(bash $HOME/Git/TranSFF/Scripts/generate_par3.sh "nokey" "$molec" "here" "$ref" 2 $raw_par)
        par_file_name=$(echo $generate_par_output | awk '{print $2}')

        select_itic_points=$(cat $HOME/Git/TranSFF/Molecules/${molec}/${molec}_select5.trho)

        bash $HOME/Git/TranSFF/Scripts/RunITIC_GOMC_Parallel.sh "$molec" ${CD}/${molec}/$ref/$par_file_name $config_filename "$select_itic_points" "$gomc_exe_address" no

        rm $par_file_name
        cat COMMANDS.parallel >> ${CD}/COMMANDS.parallel
    done
done

parallel --jobs $Nproc < COMMANDS.parallel 
