#!/bin/bash

# This script takes GOMC pdb file and runs GOMC executable using recalculate option (RunSteps=0) using new parameters in rerun par and run pdb file.
# The program exits if the rerun has already been completed before.
#
# Todo: Sometimes we need to rerun using a different pair_style. That means we should also have rerun.conf file in addition to rerun.par file 

# input number of snapshots to be skipped, the name of GOMC PDB file, the name of par file for rerun, and a name for the output .pepress file
Nsnapshots=$1				# Consider last Nsnapshots in the pdb file
GOMC_PDB=$2
rerun_par_address=$3
pepress_name=$4
GOMC_exe=$5

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

# check if rerun par file exists, if yes run Cassandra with rerun option
if [ -e "${keyword}_rerun.par" ]
then
	${GOMC_exe} "${keyword}_nvt-rerun.inp" > ${keyword}_rerun.log
	grep -R "ENER_0" ${keyword}_rerun.log | awk '{print $2,$3}' | tail -n +2 > ${keyword}.pe	# MC_STEP and TotalEnergy
	grep -R "STAT_0" ${keyword}_rerun.log | awk '{print $3}' | tail -n +2 > ${keyword}.pres		# Pressure
	paste ${keyword}.pe ${keyword}.pres > "$pepress_name"
else
	echo "Warning: ${keyword}_rerun.par was not found! No rerun simulation was done."
	rm -rf "${keyword}_nvt-rerun.inp"
fi

rm -rf ${keyword}_*





# Here, We preprocess the big .xyz file to match what we need to input Cassandra. Typically, only 1000 snapshots are enough, but often we have stored more so we skip the first n snpshots. 
#nHeaderLines=2 
#nTailLines=1
#nsnapshots0=$(grep -c "REMARK" "${GOMC_PDB}")	# Number of snapshots in the modified PDB file
#natoms=$(grep -R "NATOM" nvt_merged.psf | awk '{print$1}')
#From=$(echo "$NskipSnapshot*($natoms+$nHeaderLines+$nTailLines) + 1" | bc)
#< ${GOMC_PDB} tail -n +"$From" > "${keyword}_for_rerun.pdb"

# Here, we renumber the extracted frames starting from 1. This operation is very slow, so we avoid it for now
#nsnapshots1=$(grep -c "REMARK" "${keyword}_for_rerun.pdb")	# Number of snapshots in the modified PDB file
#if [ "$nsnapshots0" != "$nsapshots1" ]
#then
#	for i in $(seq 1 $nsnapshots1)	# This for loop is expensive
#	do
		#ith_remark_line=$(grep "REMARK" "${keyword}_for_rerun.pdb" | sed -n "$i"p)
		#mc_step=$(echo $ith_remark_line | awk '{print $4}')
		#line_number_to_replace=$(echo "($i-1)*($natoms+$nHeaderLines+$nTailLines) + 1" | bc)
		#sed -i "$line_number_to_replace""s/.*/REMARK     GOMC $i $mc_step                                            /" "${keyword}_for_rerun.pdb"
#	done
#fi