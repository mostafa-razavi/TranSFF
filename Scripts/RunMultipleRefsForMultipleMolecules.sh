#!/bin/bash
CD=${PWD}

molecules_array="C4 C12 C8"
ref_array="3.780-127.00_4.030-53.00 3.790-125.00_4.020-56.00 3.800-123.00_4.000-58.00 3.810-121.00_3.990-60.00 3.820-119.00_3.980-63.00"
config_filename="FSHIFT_BULK_4M.conf"
Nproc=$(nproc)
gomc_exe_address="$HOME/Git/GOMC/GOMC-FSHIFT2-SWF-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"


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

    select_itic_points=$(cat $HOME/Git/TranSFF/Molecules/${molec}/${molec}_select9.trho)

    bash $HOME/Git/TranSFF/Scripts/RunITIC_GOMC_Parallel.sh "$molec" ${CD}/${molec}/$ref/$par_file_name $config_filename "$select_itic_points" "$gomc_exe_address" no

    rm $par_file_name
    cat COMMANDS.parallel >> ${CD}/COMMANDS.parallel
  done
done

parallel --jobs $Nproc < ${CD}/COMMANDS.parallel 
