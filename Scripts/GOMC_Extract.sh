#!/bin/bash

# This script takes GOMC pdb file and reruns a PDB file via recalculate option (RunSteps=0) using 
# new parameters in rerun par file and optinally new key-value pairs specified in rerun_inp_address
# The program exits if the rerun has already been completed before.

Nsnapshots=$1			# Number of snapshots in the PDB file. Currently, the last Nsnapshots in the pdb file is read
pepress_name=$2			# The name of the rerun output (.rer file) that contains the values of energy and pressure

if [ -e "$pepress_name" ]
then
	echo "The rerun ${PWD}/$pepress_name already exists."
	exit
fi

# We pick a keyword to distinguish different processes working in the same simulation directory by introducing a unique keyword at the begining of all related files.
keyword=$(date +"%Y.%m.%d.%H.%M.%S.%N")

# check if gomc.log file exists, if yes extract energy and pressure from it
if [ -e "gomc.log" ]
then
	grep -R "ENER_0" gomc.log | awk '{print $3,$4,$5,$6,$7,$8}' > ${keyword}.ener_0			# TOTAL, INTRA(B),  INTRA(NB), INTER(LJ), LRC, TOTAL_ELECT 
	grep -R "STAT_0" gomc.log | awk '{print $2,$3,$4,$5}' > ${keyword}.stat_0					# STEP, PRESSURE, TOTALMOL, TOT_DENSITY

	cat ${keyword}.stat_0 | awk '{print $1}' > ${keyword}.step
	cat ${keyword}.stat_0 | awk '{print $2}' > ${keyword}.pres

	paste ${keyword}.step ${keyword}.pres ${keyword}.ener_0 | tail -n${Nsnapshots} > "$pepress_name"	# STEP, PRESSURE, TOTAL, INTRA(B), INTRA(NB), INTER(LJ), LRC, TOTAL_ELECT 
else
	echo "Warning: gomc.log was not found! Nothing was done."
fi

rm -rf ${keyword}*