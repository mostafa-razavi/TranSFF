#!bin/bash

# This script outputs the MBAR predictions from reference ITIC GOMC simulations. It should run in the directory where the reference simulations exist.
CD=${PWD}

ref_ff_string=$1
target_par=$2
target_inp=$3
Nsnapshots=$4
Ncores=$5
GOMC_exe=$6
Selected_Ts=$7
Selected_rhos=$8

# Create an array of reference force fields' names
IFS=', ' read -r -a ref_ff_array <<< "$ref_ff_string"

target_ff_name="${target_par%.*}"

if [ "$target_inp" == "none" ]; then
    target_inp_name=""
    rerun_inp_address="none"
else
    target_inp_name="${target_inp%.*}"
    rerun_inp_address="$CD/${target_inp}"
fi
target_ff_name=${target_ff_name}${target_inp_name}

# Make a copy of ref_ff_array and the target_ff_name
all_ff_array=("${ref_ff_array[@]}")
all_ff_array+=("$target_ff_name")

# Generate a name for mbar_itic run
for i in ${ref_ff_array[@]}
do
    parallel_file_name="${parallel_file_name}$i.ref_"
done
parallel_file_name="${parallel_file_name}${target_ff_name}.target"

# Function that returns 1 if the T_rho pair is selected 
isFolderSelected () {
    local iRhoOrT
	path_string=$1
	T_array=$2
	rho_array=$3

	# If temperature or density array is "all" it means that all ITIC points are selected, so we return 1
	if [ "$T_array" == "all" ] || [ "$rho_array" == "all" ]; then 
		return 1
	fi

	T_array=($T_array)
	rho_array=($rho_array)

	IFS='/' read -ra IX_Y_Z <<< "$path_string"
	IT_or_IC=${IX_Y_Z[-3]}
	rho_or_T1=${IX_Y_Z[-2]}
	rho_or_T2=${IX_Y_Z[-1]}

	if [ "$IT_or_IC" == "IC" ]; then
		rho=$rho_or_T1
		T=$rho_or_T2
	fi
	if [ "$IT_or_IC" == "IT" ]; then
		rho=$rho_or_T2
		T=$rho_or_T1
	fi


	for iRhoOrT in $(seq 0 1 $(echo "${#rho_array[@]}-1" | bc))	# Loop from 0 to len(rho_array)-1
	do
		if [ "$rho" == "${rho_array[iRhoOrT]}" ] && [ "$T" == "${T_array[iRhoOrT]}" ]; then
  			return 1
		fi
	done
}

# Prepare the .rer files in parallel
rm -rf $parallel_file_name.parallel
for j in ${all_ff_array[@]}
do
    for i in ${ref_ff_array[@]}
    do
        for k in $CD/$i/I*/*/*/
        do 
            isFolderSelected "$k" "$Selected_Ts" "$Selected_rhos"
	        if [ "$?" == "1" ]; then
                if [ "$j" == "$target_ff_name" ]
                then
                    rerun_par_address="$CD/${target_par}"
                else
                    rerun_par_address=$(ls $CD/$j/Files/*.par)
                fi
                # Arguments: Nsnapshots=$1 GOMC_PDB=$2 rerun_par_address=$3 output_name=$4             
                echo "cd $k; bash /home/mostafa/Git/TranSFF/Scripts/GOMC_Rerun.sh $Nsnapshots nvt_BOX_0.pdb ${rerun_par_address} ${rerun_inp_address} $i.ref_$j.rer ${GOMC_exe}" >> $parallel_file_name.parallel
            fi
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
        isFolderSelected "$k" "$Selected_Ts" "$Selected_rhos"
        if [ "$?" == "1" ]; then    
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
                python3.6 /home/mostafa/Git/TranSFF/Scripts/MBAR_predict.py "$Temp" "$Nsnapshots" "$ref_sim_fol_string" "$ref_ff_string" "$target_ff_name" "$which_datafile_columns_string" "$how_many_datafile_rows_to_skip" "$energy_unit" >> "$CD/${parallel_file_name}.res"
            fi
        fi
    done
done
