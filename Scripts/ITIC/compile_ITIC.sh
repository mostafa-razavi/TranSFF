#!/bin/bash

Dir="$HOME/Git/TranSFF/Scripts/ITIC"

gfortran -o "$Dir/ITIC" "$Dir/ITIC.f90" "$Dir/LmdifEzCov2.for" "$Dir/MinTools.for"
gfortran -o "$Dir/ITIC_pick" "$Dir/ITIC_pick.f90" "$Dir/LmdifEzCov2.for" "$Dir/MinTools.for"
gfortran -o "$Dir/GEMC_pick" "$Dir/GEMC_pick.f90" "$Dir/LmdifEzCov2.for" "$Dir/MinTools.for"
