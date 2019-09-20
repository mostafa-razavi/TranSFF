#!/bin/bash
# This script runs the ITIC simulations in parallel. If the third argument is not specified the script used all cores available.
# Example: Run butane usinng 32 cores
# bash RunITIC_GOMC_Parallel.sh C4 C4_TraPPE-UA.par FSHIFT_BULK_LONG.conf "360.00/0.6220 0.6220/95.00" yes 5
# bash RunITIC_GOMC_Parallel.sh C4 C4_TraPPE-UA.par FSHIFT_BULK_LONG.conf all no
#
# S. Mostafa Razavi (sr87@zips.uakron.edu)


#===== Molecule and force field files =====
molec_name=$1									# E.g. C1, C2, C4, C12, etc
force_field_file_name=$2						# E.g. C2_TraPPE-UA.par
config_filename=$3								# A file containing GOMC settings (a list of key value pairs e.g. Potential	FSHIFT\n LRC false)
Trho_rhoT_pairs_array=$4						# "all" or pairs of temperature/density (for IT) and density/temperatures (for IC) that we want to run, e.g. 360.00/0.6220 or 0.6220/95.00
should_run=$5									# "yes" or "no" (lower case)

ITIC_file_name="${molec_name}.itic"
pdb_file_name="${molec_name}.pdb"
topology_file_name="${molec_name}.top"
config_file="$HOME/Git/TranSFF/Scripts/${config_filename}"

#===== Number of CPU cores to use ===== 
Nproc=$(nproc)
if [ "$6" != "" ]; then Nproc="$6"; fi

#===== Simulation Parameters =====
Restart=$(grep -R "Restart" $config_file | head -n1 | awk '{print $2}')
Potential=$(grep -R "Potential" $config_file | awk '{print $2}')
LRC=$(grep -R "LRC" $config_file | awk '{print $2}')
Rcut=$(grep -R "Rcut" $config_file | awk '{print $2}')
PressureCalc=$(grep -R "PressureCalc" $config_file | awk '{print $2}')
RunSteps=$(grep -R "RunSteps" $config_file | awk '{print $2}')
EqSteps=$(grep -R "EqSteps" $config_file | awk '{print $2}')
AdjSteps=$(grep -R "AdjSteps" $config_file | awk '{print $2}')
CoordinatesFreq=$(grep -R "CoordinatesFreq" $config_file | awk '{print $2}')
RestartFreq=$(grep -R "RestartFreq" $config_file | awk '{print $2}')
ConsoleFreq=$(grep -R "ConsoleFreq" $config_file | awk '{print $2}')
BlockAverageFreq=$(grep -R "BlockAverageFreq" $config_file | awk '{print $2}')
OutputName=$(grep -R "OutputName" $config_file | awk '{print $2}')

#===== Important paths =====
Scripts_path="$HOME/Git/TranSFF/Scripts"
Molecules_path="$HOME/Git/TranSFF/Molecules/$molec_name"
Forcefileds_path="$HOME/Git/TranSFF/Forcefields/$molec_name"

#===== Executable files =====
gomc_exe_address="$HOME/Git/GOMC/GOMC-FSHIFT2-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"
packmol_exe_address="$HOME/Git/packmol/packmol-18.169-precise/bin/packmol"
vmd_exe_address="vmd"

#===== Input files =====
gomc_input_file_name="nvt.inp"
psfgen_input_file_name="psfgen.tcl"
packmol_input_file_name="packmol.in"

#===== Other =====
continue_if_Files_folder_exists="yes"




# Function that returns 1 if the T_rho pair is selected 
isTrhoPairSelected () {
    local iRhoOrT
	path_string="$1"
	T_rho_array="$2"

	T_rho_array=($T_rho_array)

	IFS='/' read -ra IX_Y_Z <<< "$path_string"
	IT_or_IC=${IX_Y_Z[-3]}
	rho_or_T1=${IX_Y_Z[-2]}
	rho_or_T2=${IX_Y_Z[-1]}

	if [ "$IT_or_IC" == "IC" ]; then
		rho=$rho_or_T1
		T=$rho_or_T2
		pair="$rho/$T"
	fi
	if [ "$IT_or_IC" == "IT" ]; then
		rho=$rho_or_T2
		T=$rho_or_T1
		pair="$T/$rho"
	fi

	for iRhoOrT in $(seq 0 $(echo "${#T_rho_array[@]}-1" | bc))	# Loop from 0 to len(rho_array)-1
	do
		if [ "${T_rho_array[iRhoOrT]}" == "$pair" ]; then
			echo "found"
			exit
		fi
	done
}


#=============================================================================================================
set -e
CD=${PWD}
this_scripts=${0}
if [ ! -e "$(basename -- "$this_scripts")" ]; then cp ${this_scripts} .; fi	# Copy the script in the current directory

if [ $continue_if_Files_folder_exists != "yes" ] && [ $continue_if_Files_folder_exists != "no" ]; then echo "continue_if_Files_folder_exists should either be yes or no. Existing..."; exit; fi
if [ -e "Files" ] && [ $continue_if_Files_folder_exists == "yes" ]; then echo "Files folder exists. Proceeding..."; fi
if [ -e "Files" ] && [ $continue_if_Files_folder_exists == "no" ]; then echo "Files folder exists. Exiting..."; exit; fi
if [ ! -e "Files" ]; then mkdir Files; fi

cd Files 
bash $Scripts_path/Generate_PDB_PSF.sh \
	$molec_name $ITIC_file_name \
	$pdb_file_name $topology_file_name \
	$packmol_input_file_name \
	$psfgen_input_file_name \
	$packmol_exe_address \
	$vmd_exe_address \
	$Scripts_path \
	$Molecules_path \
	$Forcefileds_path 
cd $CD

if [ -e "IT" ] || [ -e "IC" ]
then
	echo "IT or IC folder already exists. Exiting..."
	exit
else
	ITIC_file_address="$Molecules_path/$ITIC_file_name" 
	cp $ITIC_file_address Files
	cp $Scripts_path/$gomc_input_file_name Files
	cp $Forcefileds_path/$force_field_file_name Files
	parameter_file="$force_field_file_name"
	gomc_input_file_replacements=( ${gomc_input_file_name} ${Restart} ${parameter_file} $Potential $LRC $Rcut $PressureCalc $RunSteps $EqSteps $AdjSteps $CoordinatesFreq $RestartFreq $ConsoleFreq $BlockAverageFreq $OutputName )
	bash $Scripts_path/MakeITIC_GOMC.sh "$CD/Files/$ITIC_file_name" "${gomc_input_file_replacements[@]}"

	rm -rf COMMANDS.parallel
	if [ "$Trho_rhoT_pairs_array" == "all" ]; then
		for fol in I*/*/*/; do 
			echo "cd $CD/$fol; $gomc_exe_address $gomc_input_file_name > gomc.log" >> COMMANDS.parallel
		done
	else
		for fol in I*/*/*/; do 
			if [ "$(isTrhoPairSelected "$fol" "$Trho_rhoT_pairs_array")" == "found" ]; then	
				echo "cd $CD/$fol; $gomc_exe_address $gomc_input_file_name > gomc.log" >> COMMANDS.parallel
			fi
		done		
	fi
	if [ "$should_run" == "yes" ]; then
		parallel --jobs $Nproc < COMMANDS.parallel
	fi
fi

#if [ "$should_run" == "yes" ]; then
#	bash $HOME/Git/TranSFF/Scripts/GONvtRdr/GONvtRdr.sh nvt.inp nvt
#	ndataskip=$(echo "($RunSteps/$BlockAverageFreq)/2" $config_file | bc )
#	nblocks="5"
#	bash $HOME/Git/TranSFF/Scripts/GONvtRdr/GONVT_BlockAvg.sh Blk_${OutputName}_BOX_0.dat $ndataskip $nblocks
#fi