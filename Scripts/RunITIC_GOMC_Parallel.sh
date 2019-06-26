#!/bin/bash
# This script runs the ITIC simulations in parallel
#
# S. Mostafa Razavi (sr87@zips.uakron.edu)


#===== Number of CPU cores to use ===== 
Nproc="4"

#===== Molecule and force field files =====
molec_name="C2"
ITIC_file_name="C2.itic"
pdb_file_name="C2.pdb"
topology_file_name="C2.top"
force_field_file_name="C2_TraPPE-UA.par"

#===== Simulation Parameters =====
Restart="false"
Potential="VDW"
LRC="true"
Rcut="14"
PressureCalc="1000"
RunSteps="100000"
EqSteps="50"
AdjSteps="50"
CoordinatesFreq="1"
RestartFreq="1000"
ConsoleFreq="1"
BlockAverageFreq="1"
OutputName="out"

#===== Important paths =====
Scripts_path="/home/mostafa/myProjects/myMBAR/Scripts"
Molecules_path="/home/mostafa/myProjects/myMBAR/Molecules/$molec_name"
Forcefileds_path="/home/mostafa/myProjects/myMBAR/Forcefields"

#===== Executable files =====
gomc_exe_address="~/Git/GOMC/GOMC-highPrecision/bin/GOMC_CPU_NVT"
packmol_exe_address="~/Git/packmol/packmol-18.169-precise/bin/packmol"
vmd_exe_address="vmd"

#===== Input files =====
gomc_input_file_name="nvt.inp"
psfgen_input_file_name="psfgen.tcl"
packmol_input_file_name="packmol.in"













#=============================================================================================================
set -e
CD=${PWD}
this_scripts=${0}
if [ ! -e "$(basename -- "$this_scripts")" ]; then cp ${this_scripts} .; fi	# Copy the script in the current directory

if [ -e "Files" ]; then echo "Files folder exists. Exiting..."; fi
mkdir Files 
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

	parallel --jobs $Nproc < COMMANDS.parallel
fi

#bash ~/Git/GONvtRdr.sh/GONvtRdr.sh