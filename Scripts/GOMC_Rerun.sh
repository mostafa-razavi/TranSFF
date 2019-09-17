#!/bin/bash

# This script takes GOMC pdb file and reruns a PDB file via recalculate option (RunSteps=0) using 
# new parameters in rerun par file and optinally new key-value pairs specified in rerun_inp_address
# The program exits if the rerun has already been completed before.

Nsnapshots=$1			# Number of snapshots in the PDB file. Currently, the last Nsnapshots in the pdb file is read
GOMC_PDB=$2				# The name of the PDB file produced by GOMC
rerun_par_address=$3	# The adress of the rerun .par file that contains the force field information
rerun_inp_address=$4	# The address of a .inp file in which updates key values are stored. For example, if "Potential VDW" would exists in ths file the value of "Potential" key is going to be updated to "VDW". This file can contain more than one key-value pairs.
pepress_name=$5			# The name of the rerun output (.rer file) that contains the values of energy and pressure
GOMC_exe=$6				# Path to the GOMC executable file

if [ -e "$pepress_name" ]
then
	echo "The rerun ${PWD}/$pepress_name already exists."
	exit
fi

# We pick a keyword to distinguish different processes working in the same simulation directory by introducing a unique keyword at the begining of all related files.
keyword=$(date +"%Y.%m.%d.%H.%M.%S.%N")
cp $rerun_par_address "${keyword}_rerun.par"

# check if xyz file exists
if [ ! -e "$GOMC_PDB" ]
then
	echo "Error: $GOMC_PDB was not found."
	exit
fi

cp ${GOMC_PDB} "${keyword}_for_rerun.pdb"

# GOMC assumes that the first snapshot has the frame number of 1. I modified GOMC code so that it reads the starting frame from StartFrame.txt. Here we create this file
N_total_snapshots=$(grep -c "REMARK" "${GOMC_PDB}")	# Number of snapshots in the modified PDB file
StartFrame=$(echo "$N_total_snapshots-$Nsnapshots" | bc)
if [ ! -e "StartFrame.txt" ]
then 
	StartFrame=$(echo "$StartFrame" | bc)
	echo $StartFrame  > StartFrame.txt
else
	ExistingStartFrame=$(cat StartFrame.txt | awk '{print $1}')
	if [ "$ExistingStartFrame" != "$StartFrame" ]
	then
		echo "Error: The starting frame in existing StartFrame.txt is not equal to the intended starting frame"
		exit
	fi
fi

# Generate rerun input file and make necessary changes. 
cp nvt.inp "${keyword}_nvt-rerun.inp"
sed -i "s/OutputName  nvt/OutputName  ${keyword}_nvt.rerun/g" "${keyword}_nvt-rerun.inp"
sed -i "s/Restart	 	false/Restart	 	true/g" "${keyword}_nvt-rerun.inp"

parameters_line=$(grep -R "Parameters" "${keyword}_nvt-rerun.inp")
sed -i "s:$parameters_line:Parameters ${keyword}_rerun.par:g" "${keyword}_nvt-rerun.inp"

coordinates_line=$(grep -R "Coordinates 0" "${keyword}_nvt-rerun.inp")
sed -i "s:$coordinates_line:Coordinates 0 ${keyword}_for_rerun.pdb:g" "${keyword}_nvt-rerun.inp"

runsteps_line=$(grep -R "RunSteps" "${keyword}_nvt-rerun.inp")
sed -i "s/$runsteps_line/RunSteps 0/g" "${keyword}_nvt-rerun.inp"

if [ "$rerun_inp_address" != "none" ]; then
	cp $rerun_inp_address "${keyword}_rerun_modifications.inp"
	key_array=( $(awk '{print $1}' "${keyword}_rerun_modifications.inp") )
	val_array=( $(awk '{print $2}' "${keyword}_rerun_modifications.inp") )
	
	for i in $(seq 0 1 $(echo "${#key_array[@]}-1" | bc))
	do
		key_value_line=$(grep -R "${key_array[i]}" "${keyword}_nvt-rerun.inp")
		sed -i "s/$key_value_line/${key_array[i]}    ${val_array[i]}/g" "${keyword}_nvt-rerun.inp"
	done
fi

# check if rerun par file exists, if yes run GOMC with recalculate option
if [ -e "${keyword}_rerun.par" ]
then
	${GOMC_exe} "${keyword}_nvt-rerun.inp" > ${keyword}_rerun.log
	grep -R "ENER_0" ${keyword}_rerun.log | awk '{print $3,$4,$5,$6,$7,$8}' | tail -n +2 > ${keyword}.ener_0			# TOTAL, INTRA(B),  INTRA(NB), INTER(LJ), LRC, TOTAL_ELECT 
	grep -R "STAT_0" ${keyword}_rerun.log | awk '{print $2,$3,$4,$5}' | tail -n +2 > ${keyword}.stat_0					# STEP, PRESSURE, TOTALMOL, TOT_DENSITY

	cat ${keyword}.stat_0 | awk '{print $1}'  > ${keyword}.step
	cat ${keyword}.stat_0 | awk '{print $2}'  > ${keyword}.pres

	paste ${keyword}.step ${keyword}.pres ${keyword}.ener_0 > "$pepress_name"	# STEP, PRESSURE, TOTAL, INTRA(B), INTRA(NB), INTER(LJ), LRC, TOTAL_ELECT 
else
	echo "Warning: ${keyword}_rerun.par was not found! No rerun simulation was done."
	rm -rf "${keyword}_nvt-rerun.inp"
fi

#rm -rf ${keyword}*