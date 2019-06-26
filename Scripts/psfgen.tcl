psfgen <<ENDMOL
topology top_file

segment some_molec_name {
 pdb in.pdb
 auto angles dihedrals
 first none
 last none
 }

writepsf out.psf

