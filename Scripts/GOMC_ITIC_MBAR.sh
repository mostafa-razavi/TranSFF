#!bin/bash

# This script outputs the MBAR predictions from reference ITIC GOMC simulations. It should run in the directory where the reference simulations exist.
CD=${PWD}

ref_ff_string=$1
target_par=$2
Nsnapshots=$3
Ncores=$4
GOMC_exe=$5

# Create an array of reference force fields' names
IFS=', ' read -r -a ref_ff_array <<< "$ref_ff_string"

target_ff_name="${target_par%.*}"

# Make a copy of ref_ff_array and the target_ff_name
all_ff_array=("${ref_ff_array[@]}")
all_ff_array+=("$target_ff_name")

# Generate a name for mbar_itic run
for i in ${ref_ff_array[@]}
do
    parallel_file_name="${parallel_file_name}$i.ref_"
done
parallel_file_name="${parallel_file_name}${target_ff_name}.target"

# Prepare the .rer files in parallel
rm -rf $parallel_file_name.parallel
for j in ${all_ff_array[@]}
do
    for i in ${ref_ff_array[@]}
    do
        for k in $CD/$i/I*/*/*/
        do
            if [ "$j" == "$target_ff_name" ]
            then
                rerun_par_address="$CD/${target_par}"
            else
                rerun_par_address=$(ls $CD/$j/Files/*.par)
            fi
            # Arguments: Nsnapshots=$1 GOMC_PDB=$2 rerun_par_address=$3 output_name=$4             
            echo "cd $k; bash /home/mostafa/Git/TranSFF/Scripts/GOMC_Rerun.sh $Nsnapshots nvt_BOX_0.pdb ${rerun_par_address} $i.ref_$j.rer ${GOMC_exe}" >> $parallel_file_name.parallel
        done
    done
done
parallel --jobs $Ncores < $parallel_file_name.parallel > $parallel_file_name.log

# Post-process the results and obtain 
rm -rf "$CD/${parallel_file_name}.res"
echo "Address Neff u[K] u_err[K] P[bar] P_err[bar]" >> "$CD/${parallel_file_name}.res"
for i in ${ref_ff_array[@]}
do
    for k in $CD/$i/I*/*/*/
    do     
        if [ "$i" == "${ref_ff_array[0]}" ]
        then
            ref_sim_fol_string=""
            for l in ${ref_ff_array[@]}
            do
                string=$(echo "$k" | sed "s/$i/$l/")
                ref_sim_fol_string="${ref_sim_fol_string} ${string}"
            done

            Temp=$(grep -R "Temperature" $k/nvt.inp| awk '{print $2}')
            which_datafile_columns_string="1 2"   #Total_En Press (0 is first column)
            how_many_datafile_rows_to_skip="0"
            energy_unit="K"
            python3.5 /home/mostafa/Git/TranSFF/Scripts/MBAR_predict.py "$Temp" "$Nsnapshots" "$ref_sim_fol_string" "$ref_ff_string" "$target_ff_name" "$which_datafile_columns_string" "$how_many_datafile_rows_to_skip" "$energy_unit" >> "$CD/${parallel_file_name}.res"
        fi
    done
done
