#/bin/bash

ranges_file=$1

rm -rf result.txt
how_many_parameter_sets_per_molec="5"

for molec in C2E C3E 1C4E 1C8E IC4E
do
    if [ "$molec" == "C2E" ]; then molecules_sites="CH2= CH2="
    elif  [ "$molec" == "C3E" ]; then molecules_sites="CH3 CH2= CH="
    elif  [ "$molec" == "1C4E" ]; then molecules_sites="CH3 CH2 CH2= CH="
    elif  [ "$molec" == "1C8E" ]; then molecules_sites="CH3 CH2 CH2= CH="
    elif  [ "$molec" == "IC4E" ]; then molecules_sites="CH3 CH2= C="
    fi

    output=$(python3.6 $HOME/Git/TranSFF/Scripts/pick_random_reference_parameter_sets/pick_random_reference_parameter_sets.py $ranges_file no-names no-n "$molecules_sites" $how_many_parameter_sets_per_molec)
    echo $molec $output >> result.txt
done