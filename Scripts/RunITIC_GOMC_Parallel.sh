#!/bin/bash
# This script runs the ITIC simulations in parallel. If the third argument is not specified the script used all cores available.
# Example: Run butane usinng 32 cores
# bash RunITIC_GOMC_Parallel.sh C4 C4_TraPPE-UA.par 32
#
# S. Mostafa Razavi (sr87@zips.uakron.edu)


#===== Molecule and force field files =====
molec_name=$1									# E.g. C1, C2, C4, C12, etc
force_field_file_name=$2						# C2_TraPPE-UA.par
should_run=$3									# "yes" or "no" (lower case)
ITIC_file_name="${molec_name}.itic"
pdb_file_name="${molec_name}.pdb"
topology_file_name="${molec_name}.top"

#===== Number of CPU cores to use ===== 
Nproc=$(nproc)
if [ "$4" != "" ]; then Nproc="$4"; fi

#===== Simulation Parameters =====
Restart="false"
Potential="FSHIFT"
LRC="false"
Rcut="14"
PressureCalc="1000"
RunSteps="10000000"
EqSteps="500000"
AdjSteps="1000"
CoordinatesFreq="5000"
RestartFreq="1000000"
ConsoleFreq="5000"
BlockAverageFreq="5000"
OutputName="nvt"

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
	for fol in I*/*/*/; do 
		echo "cd $CD/$fol; $gomc_exe_address $gomc_input_file_name > gomc.log" >> COMMANDS.parallel
	done
	if [ "$should_run" == "yes" ]; then
		parallel --jobs $Nproc < COMMANDS.parallel
	fi
fi

if [ "$should_run" == "yes" ]; then
	bash ~/Git/TranSFF/Scripts/GONvtRdr/GONvtRdr.sh nvt.inp nvt
fi