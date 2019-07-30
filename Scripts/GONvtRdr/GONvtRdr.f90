program main
	implicit double precision (A-H,O-Z)
	character :: dumString1*200,dumString2*200,String*200,dumStr*5
	CHARACTER(300) :: Address,Directory,FolderName,myName,AddressString,outFile,psfFile,datFile,inputFile
 	INTEGER*4 getcwd 

	call getarg(1,datFile)
	call getarg(2,inputFile)
	call getarg(3,psfFile)
	call getarg(4,outFile)

	if(datFile.eq."man".OR.datFile.eq."MAN")then
		write(*,*)
		write(*,*)"	You can run this program using following options:	"
		write(*,*)
		write(*,*)"		$./GONvtRdr datFile inputFile psfFile outFile	"
		write(*,*)
		write(*,*)"	For example	"
		write(*,*)
		write(*,*)"		$./GONvtRdr Blk_out_BOX_0.dat in.conf out_merged.psf GONvtRdr.results	"
		write(*,*)
	stop
	endif

	iError=0
	open(21,file=trim(inputFile))
		do while(iError.eq.0)	
			read(21,*,iostat=iError) dumString1
		  	dumString1 = TRIM(dumString1)
			if(dumString1.eq."Temperature") then
				backspace 21
				read(21,*) dumString1,T
			endif
			if(dumString1.eq."RunSteps") then
				backspace 21
				read(21,*) dumString1,RunSteps
			endif
			if(dumString1.eq."BlockAverageFreq") then
				backspace 21
				read(21,*) dumString1,dumString1,BlockAverageFreq
			endif	
			!Extracts rho based on the following line in input file
			!	Coordinates 0    ../../../DataFiles/0.02364/0.02364.pdb
			!if(dumString1.eq."Coordinates") then
			!	backspace 21
			!	read(21,'(A)') AddressString !,dumString1,AddressString
			!	AddressString=trim(AddressString)
			!	index=scan(AddressString,"/",.true.)
			!	AddressString=AddressString(index+1:)
			!	index=scan(AddressString,".pdb",.true.)
			!	AddressString=AddressString(:index-4)
			!	read(AddressString,*)rho
			!endif	
		end do
	close(21)


	nData=RunSteps/BlockAverageFreq
	!nData=142

	i=0
	j=0
	iErr=0
	step = 0

	v1 = 0
	v2 = 0
	v3 = 0
	v4 = 0
	v5 = 0
	v6 = 0
	v7 = 0
	v8 = 0
	v9 = 0
	v10 = 0
	v11 = 0
	v12 = 0

	TOT_EN = 0
	EN_INTER = 0
	EN_TC = 0
	EN_INTRA_B = 0
	EN_INTRA_NB = 0
	EN_ELECT = 0
	EN_REAL = 0
	EN_RECIP = 0
	TOTAL_VIR = 0
	PRESSURE = 0
	TOT_MOL = 0
	TOT_DENS = 0
  
	weight = 0.0d0
!STEPS TOT_EN EN_INTER EN_TC EN_INTRA_B EN_INTRA_NB EN_ELECT EN_REAL EN_RECIP TOTAL_VIR PRESSURE TOT_MOL TOT_DENS   
	open(1,file=trim(datFile))
	read(1,*)dumString1
	read(1,*)	!skip the first row of data because of the output bug in GOMC
	i = i + 1 	! Add one to i
		do
			read(1,*,iostat=iErr)step,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12
			i=i+1
			if(iErr.ne.0) exit
			if(iErr.eq.0.AND.i.gt.nData/2.0) then
				j = j + 1
				TOT_EN = TOT_EN + v1
				EN_INTER = EN_INTER + v2
				EN_TC = EN_TC + v3
				EN_INTRA_B = EN_INTRA_B + v4
				EN_INTRA_NB = EN_INTRA_NB + v5
				EN_ELECT = EN_ELECT + v6
				EN_REAL = EN_REAL + v7
				EN_RECIP = EN_RECIP + v8
				TOTAL_VIR = TOTAL_VIR + v9
				PRESSURE = PRESSURE + v10
				TOT_MOL = TOT_MOL + v11
				TOT_DENS = TOT_DENS + v12

				pSq = pSq + v10*v10
			endif
		enddo
		TOT_EN = TOT_EN / j
		EN_INTER = EN_INTER / j
		EN_TC = EN_TC / j
		EN_INTRA_B = EN_INTRA_B / j
		EN_INTRA_NB = EN_INTRA_NB / j
		EN_ELECT = EN_ELECT / j
		EN_REAL = EN_REAL / j
		EN_RECIP = EN_RECIP / j
		TOTAL_VIR = TOTAL_VIR / j
		PRESSURE = PRESSURE / j
		TOT_MOL = TOT_MOL / j
		TOT_DENS = TOT_DENS / j
		pSq = pSq / j
	close(1)

	open(88,file=trim(psfFile))
		do
			read(88,*)dumString1,dumString2
			if(dumString2.eq."!NATOM") then
				read(dumString1,*)nAtoms			
				exit
			endif
		enddo
		!read(88,*)nAtoms
		do i=1,nAtoms
			read(88,*)iAtom,dumStr,iMolec,dumStr,dumStr,dumStr,dumStr,w
			weight=weight+w
			if(iMolec.eq.2) then
			weight=weight-w
			nAtomsPerMolec=i-1
			N=nAtoms/nAtomsPerMolec
			exit
			endif
		enddo
	close(88)
	!write(*,*) weight,N,nAtoms,nAtomsPerMolec
	status=getcwd( Address ) 
   	Address = TRIM(Address)
	index = SCAN(Address,"/",.true.)
	Directory = Address(1:index-1)
	FolderName = Address(index+1:)
	
	rho = TOT_DENS / 1000.0
	press_Atm=PRESSURE*0.986923
	Z=PRESSURE*weight/(rho*8.314*T)*0.10
	stDevP=SQRT( (150)*(pSq-PRESSURE*PRESSURE)/((150)-1) )
	stDevZ=stDevP*weight/(rho*8.314*T)*0.10
	ePot=TOT_EN*0.0019872041
	eMol=EN_INTRA_B*0.0019872041
	eVdw=(EN_INTER+EN_TC)*0.0019872041
	eIVdw=EN_INTRA_NB*0.0019872041

!STEPS TOT_EN EN_INTER EN_TC EN_INTRA_B EN_INTRA_NB EN_ELECT EN_REAL EN_RECIP TOTAL_VIR PRESSURE TOT_MOL TOT_DENS   
!EnergyIntraBond     EnergyIntraNonbond  EnergyTC EnergyTotal Pressure VirialTotal

	!write(*,*) T, rho, RunSteps, BlockAverageFreq,nData,TOT_DENS

	write(*,*)
	write(*,'(A,A)')"Folder Name: ",trim(FolderName)
	write(*,*)
	write(*,'(A25,3x,f15.3)')"TOT_EN(K)= ",TOT_EN
	write(*,'(A25,3x,f15.3)')"EN_INTER(K)= ",EN_INTER
	write(*,'(A25,3x,f15.3)')"EN_TC(K)= ",EN_TC
	write(*,'(A25,3x,f15.3)')"EN_INTRA_B(K)= ",EN_INTRA_B
	write(*,'(A25,3x,f15.3)')"EN_INTRA_NB(K)= ",EN_INTRA_NB
	write(*,'(A25,3x,f15.3)')"EN_ELECT(K)= ",EN_ELECT
	write(*,'(A25,3x,f15.3)')"EN_REAL(K)= ",EN_REAL
	write(*,'(A25,3x,f15.3)')"EN_RECIP(K)= ",EN_RECIP
	write(*,'(A25,3x,f15.3)')"TOTAL_VIR= ",TOTAL_VIR
	write(*,'(A25,3x,f15.3)')"PRESSURE(bar)= ",PRESSURE
	write(*,'(A25,3x,f15.3)')"TOT_MOL= ",TOT_MOL
	write(*,'(A25,3x,f15.3)')"TOT_DENS(kg/m3)= ",TOT_DENS
	write(*,*)
	write(*,'(A9,1x,A9,1x,3(A9,1x),6(A15,1x),A6)')'T(K)','rho(gcc)','P(atm)','Z','Zstd','ePot(kcal/mol)','eMol(kcal/mol)','&
				eVdw(kcal/mol)','IVdw(kcal/mol)','RunSteps','EqSteps','nMolec'
	write(*,'(f9.2,1x,f9.5,1x,3(f9.3,1x),4(f15.3,1x),2(I15,1x),I6,4x,A4)') T,rho,press_Atm,Z,stDevZ,ePot,eMol,eVdw+eIVdw,eIVdw, &
										int(RunSteps),int(nData/2.0*BlockAverageFreq),N,"GOMC"
	write(*,*)

	open(88,file=trim(outFile))
	write(88,*)
	write(88,'(A,A)')"Folder Name: ",trim(FolderName)
	write(88,*)
	write(88,'(A25,3x,f15.3)')"TOT_EN(K)= ",TOT_EN
	write(88,'(A25,3x,f15.3)')"EN_INTER(K)= ",EN_INTER
	write(88,'(A25,3x,f15.3)')"EN_TC(K)= ",EN_TC
	write(88,'(A25,3x,f15.3)')"EN_INTRA_B(K)= ",EN_INTRA_B
	write(88,'(A25,3x,f15.3)')"EN_INTRA_NB(K)= ",EN_INTRA_NB
	write(88,'(A25,3x,f15.3)')"EN_ELECT(K)= ",EN_ELECT
	write(88,'(A25,3x,f15.3)')"EN_REAL(K)= ",EN_REAL
	write(88,'(A25,3x,f15.3)')"EN_RECIP(K)= ",EN_RECIP
	write(88,'(A25,3x,f15.3)')"TOTAL_VIR= ",TOTAL_VIR
	write(88,'(A25,3x,f15.3)')"PRESSURE(bar)= ",PRESSURE
	write(88,'(A25,3x,f15.3)')"TOT_MOL= ",TOT_MOL
	write(88,'(A25,3x,f15.3)')"TOT_DENS(kg/m3)= ",TOT_DENS
	write(88,*)
	write(88,'(A9,1x,A9,1x,3(A9,1x),6(A15,1x),A6)')'T(K)','rho(gcc)','P(atm)','Z','Zstd','ePot(kcal/mol)','eMol(kcal/mol)','&
				eVdw(kcal/mol)','IVdw(kcal/mol)','RunSteps','EqSteps','nMolec'
	write(88,'(f9.2,1x,f9.5,1x,3(f9.3,1x),4(f15.3,1x),2(I15,1x),I6,4x,A4)') T,rho,press_Atm,Z,stDevZ,ePot,eMol,eVdw+eIVdw,eIVdw, &
										int(RunSteps),int(nData/2.0*BlockAverageFreq),N,"GOMC"
	close(88)
end program main
