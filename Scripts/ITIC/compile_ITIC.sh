#!/bin/bash

Dir="$HOME/Git/TranSFF/Scripts/ITIC"

gfortran -o "$Dir/ITIC" "$Dir/ITIC.f90" "$Dir/LmdifEzCov2.for" "$Dir/MinTools.for"
