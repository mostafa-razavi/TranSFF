#/bin/bash

ranges_file=$1

rm -rf result.txt
how_many_parameter_sets_per_molec="4"

for molec in IC4 IC5 IC6 23MB NP 22MB 22MP IC8
do
    if [ "$molec" == "IC4" ]; then molecules_sites="CH3 CH1"
    #elif  [ "$molec" == "IC5" ]; then molecules_sites="CH3 CH2 CH1"
    elif  [ "$molec" == "IC6" ]; then molecules_sites="CH3 CH2 CH1"
    elif  [ "$molec" == "IC8" ]; then molecules_sites="CH3 CH2 CH1 CT"
    elif  [ "$molec" == "NP" ]; then molecules_sites="CH3 CT"
    #elif  [ "$molec" == "23MB" ]; then molecules_sites="CH3 CH1"
    #elif  [ "$molec" == "22MB" ]; then molecules_sites="CH3 CH2 CT"           
    #elif  [ "$molec" == "22MP" ]; then molecules_sites="CH3 CH2 CT"
    fi

    output=$(python3.6 $HOME/Git/TranSFF/Scripts/pick_random_reference_parameter_sets/pick_random_reference_parameter_sets.py $ranges_file no-names no-n "$molecules_sites" $how_many_parameter_sets_per_molec)
    echo $molec $output >> result.txt
done
