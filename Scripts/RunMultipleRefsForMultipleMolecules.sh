#!/bin/bash
CD=${PWD}

molecules_array="IC4 IC5 IC6 23MB IC8 NP 22MB 22MP"


all_ref_array[0]="3.780-123.00_4.730-25.00 3.810-122.00_4.660-16.00 3.840-118.00_4.740-20.00 3.790-120.00_4.680-10.00 3.820-120.00_4.720-18.00" #IC4
all_ref_array[1]="3.780-123.00_4.730-25.00 3.810-122.00_4.660-16.00 3.840-118.00_4.740-20.00 3.790-120.00_4.680-10.00 3.820-120.00_4.720-18.00" #IC5 
all_ref_array[2]="3.780-123.00_4.730-25.00 3.810-122.00_4.660-16.00 3.840-118.00_4.740-20.00 3.790-120.00_4.680-10.00 3.820-120.00_4.720-18.00" #IC6 
all_ref_array[3]="3.780-123.00_4.730-25.00 3.810-122.00_4.660-16.00 3.840-118.00_4.740-20.00 3.790-120.00_4.680-10.00 3.820-120.00_4.720-18.00" #23MB 
all_ref_array[4]="3.78-123_4.73-25_6.32-5 3.81-122_4.66-16_6.34-10 3.79-120_4.68-10_6.35-8 3.82-120_4.72-18_6.28-3 3.84-118_4.74-20_6.26-6" #IC8 
all_ref_array[5]="3.780-123.00_6.320-5.00 3.790-120.00_6.340-10.00 3.810-122.00_6.350-8.00 3.820-120.00_6.280-3.00 3.840-118.00_6.260-6.00" #NP 
all_ref_array[6]="3.780-123.00_6.320-5.00 3.790-120.00_6.340-10.00 3.810-122.00_6.350-8.00 3.820-120.00_6.280-3.00 3.840-118.00_6.260-6.00" #22MB 
all_ref_array[7]="3.780-123.00_6.320-5.00 3.790-120.00_6.340-10.00 3.810-122.00_6.350-8.00 3.820-120.00_6.280-3.00 3.840-118.00_6.260-6.00" #22MP 

select_key="all"

config_filename="FSHIFT_BULK_6M.conf"
Nproc=$(nproc)
gomc_exe_address="$HOME/Git/GOMC/GOMC-FSHIFT2-SWF-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"

rm -rf ${CD}/COMMANDS.parallel
molecules_array=($molecules_array)
ref_array=($ref_array)

i=-1
for molec in "${molecules_array[@]}"
do 
  i=$((i+1))
  mkdir ${CD}/${molec}

  ref_array="${all_ref_array[i]}"
  ref_array=($ref_array)

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

    if [ "$select_key" == "all" ]; then
      select_itic_points="all"
    else
      select_itic_points=$(cat $HOME/Git/TranSFF/SelectITIC/${molec}_${select_key}.trho)
    fi

    bash $HOME/Git/TranSFF/Scripts/RunITIC_GOMC_Parallel.sh "$molec" ${CD}/${molec}/$ref/$par_file_name $config_filename "$select_itic_points" "$gomc_exe_address" no

    rm $par_file_name
    cat COMMANDS.parallel >> ${CD}/COMMANDS.parallel
  done
done

parallel --jobs $Nproc < ${CD}/COMMANDS.parallel 
