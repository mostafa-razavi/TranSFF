# This script generates PDB file and PSF file necessary for running a GOMC simulation
#
#
# S. Mostafa Razavi (sr87@zips.uakron.edu)



#!/bin/bash
set -e
CD=${PWD}

if [ ! "$1" == "" ] # If the script is called with at least one arguments, it is assumed that all other arguments are also provided.
then
	molec_name=$1
	ITIC_file_name=$2
	pdb_file_name=$3
	topology_file_name=$4

	packmol_input_file_name=$5
	psfgen_input_file_name=$6

	packmol_exe_address=$7
	vmd_exe_address=$8

	Scripts_path=$9
	Molecules_path=${10}
	#Forcefileds_path=${11}

	cp $Molecules_path/$ITIC_file_name .
	cp $Molecules_path/$pdb_file_name .
	cp $Molecules_path/$topology_file_name .

	cp $Scripts_path/$packmol_input_file_name .
	cp $Scripts_path/$psfgen_input_file_name .
else	# If the script is run with no arguments, it's assumed that all the necessary files are in current directory.
	pdb_file_name=$(ls *.pdb)
	molec_name=$(basename -- "$pdb_file_name")
	ITIC_file_name=$(ls *.itic)
	topology_file_name=$(ls *.top)

	packmol_input_file_name="packmol.in"
	psfgen_input_file_name="psfgen.tcl"

	packmol_exe_address="packmol"
	vmd_exe_address="vmd"

	Scripts_path=$CD
	Molecules_path=$CD
	#Forcefileds_path=$CD
fi


MW=$(grep "MW:" ${ITIC_file_name} | awk '{print $2}')

rhos1=$(grep "RHO_IT1:" ${ITIC_file_name} | awk '{ $1="";print $0}'); rhos1=($rhos1)
rhos2=$(grep "RHO_IT2:" ${ITIC_file_name} | awk '{ $1="";print $0}'); rhos2=($rhos2)
rhos=( "${rhos1[@]}" "${rhos2[@]}"  )

Nmolec1=$(grep "NMOL_IT1:" ${ITIC_file_name} | awk '{ $1="";print $0}'); Nmolec1=($Nmolec1)
Nmolec2=$(grep "NMOL_IT2:" ${ITIC_file_name} | awk '{ $1="";print $0}'); Nmolec2=($Nmolec2)
Nmolec=( "${Nmolec1[@]}" "${Nmolec2[@]}" )

i=-1
for rho in "${rhos[@]}"
	do
	i=$(($i+1))
	N=${Nmolec[i]}
	if [ ! -e "${rho}_$N" ]
	then
		mkdir "${rho}_$N"
		L=$(echo "scale=15; e((1/3)*l($N*$MW/$rho/0.6022140857)) "   | bc -l)

		cp $CD/$pdb_file_name $CD/"${rho}_$N"/$pdb_file_name 
		cp $CD/"$packmol_input_file_name" $CD/"${rho}_$N"/$packmol_input_file_name
		cp $CD/${topology_file_name} $CD/"${rho}_$N"/${topology_file_name}
		cp $CD/${psfgen_input_file_name} $CD/"${rho}_$N"/${psfgen_input_file_name}

		sed -i "s/"pdbFile"/$pdb_file_name/g" $CD/"${rho}_$N"/$packmol_input_file_name
		sed -i "s/"NNN"/${N}/g" $CD/"${rho}_$N"/$packmol_input_file_name
		sed -i "s/"LLL"/$L/g" $CD/"${rho}_$N"/$packmol_input_file_name

		sed -i "s/"top_file"/$topology_file_name/g" $CD/"${rho}_$N"/$psfgen_input_file_name
		sed -i "s/"some_molec_name"/$molec_name/g" $CD/"${rho}_$N"/$psfgen_input_file_name

		cd "${rho}_$N"

		eval ${packmol_exe_address} < packmol.in
		mv out.txt "${rho}_$N".pdb 

		cp "${rho}_$N".pdb in.pdb
		eval ${vmd_exe_address} < ${psfgen_input_file_name}
		mv out.psf "${rho}_$N".psf

		rm in.pdb $pdb_file_name $packmol_input_file_name ${topology_file_name} ${psfgen_input_file_name}

		cd ..
	else
		echo "${rho}_$N" "directory already exists"
	fi
done