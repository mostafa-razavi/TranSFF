program	main
	implicit double precision(A-H,O-Z)

	double precision TsatSL(9),rhoLSL(9),rhoVSL(9),PsatSL(9)
	common TsatSL,rhoLSL,rhoVSL,PsatSL

	character :: LammpsRdrOut*88,RunITICinp*88,parFile*88,dumString*155,ExeName*155, &
			VirialTreatmentApplied*5,keyword*10,strInteger*2,yesOrno*3
	character :: dumString3*15,rhoText*10
	character(len=100) :: arg1,arg2,arg3,arg4,arg5
	integer, dimension (0:9) :: isVisited
	character (len=8), dimension (0:9) :: IntegrationMethod
	parameter(maxICs=11)
	parameter(maxICTs=5)
	parameter(nPointsOnIC=3)
	parameter(nMaxData=150)
	logical b0_5,b1_0,b1_5,b2_0,b2_5,b3_0
	logical f0_5,f1_0,f1_5,f2_0,f2_5,f3_0,here
	logical isNist,isLammps,isGromscs,doesVirialCalcITpointsExist,doesVirialCalcIT2pointsExist,isCriticalNeeded, isMoleculeUnknown
	logical isLinearuDepT,isQU,isLU,isRichUdep,isUdepReadFromFile,is3rdOrderPolZ,isLT,isQT,isUdepkcalReadFromFile
	logical isMixedLQ,isMixedLQ2,isThereB2ITHardCoded,isB2FromDippr,isConvergencePathNeeded
	logical isUdepFromEpotMinusSingle,isUdepFromEpotMinusSingleN
	logical isB2Applied,isB3Applied,isB4Applied,isB5Applied,isB6Applied,disableExtrapolation,isThereB2correlationFromLiterature
	double precision :: Tfile(nMaxData),rhofile(nMaxData),Pfile(nMaxData),Zfile(nMaxData),Zstdfile(nMaxData), &
			ePotfile(nMaxData),eBondfile(nMaxData),eVdwfile(nMaxData),eIntraVdwfile(nMaxData),simTimefile(nMaxData),eqTimefile(nMaxData)
	Double Precision rhoIsochore(maxICs),tIsochore(maxICs,maxICTs),zIsochore(maxICs,maxICTs),uDepIsochore(maxICs,maxICTs)
	Double Precision rhoIsochoreCalc(maxICs),T_IC_calc(maxICs,maxICTs),zIsochoreCalc(maxICs,maxICTs),uDepIsochoreCalc(maxICs,maxICTs)
	double precision :: T_IT(20),rho_IT(0:20),P_IT(20),Z_IT(20),Zstd_IT(20),ePot_IT(20),eBond_IT(20),eVdw_IT(20),&
				eIntraVdw_IT(20),simTime_IT(20), eqTime_IT(20)
	double precision :: T_IT_vr(20),rho_IT_vr(0:20),P_IT_vr(20),Z_IT_vr(20),Zstd_IT_vr(20),ePot_IT_vr(20),&
				eBond_IT_vr(20),eVdw_IT_vr(20),eIntraVdw_IT_vr(20),simTime_IT_vr(20), eqTime_IT_vr(20)
	double precision :: T_IT2_vr(20),rho_IT2_vr(0:20),P_IT2_vr(20),Z_IT2_vr(20),Zstd_IT2_vr(20),ePot_IT2_vr(20),&
				eBond_IT2_vr(20),eVdw_IT2_vr(20),eIntraVdw_IT2_vr(20),simTime_IT2_vr(20), eqTime_IT2_vr(20),uDep_over_rho_vr(4)
	double precision :: T_IC(maxICs,maxICTs),rho_IC(maxICs),P_IC(maxICs,maxICTs),Z_IC(maxICs,maxICTs), &
		Zstd_IC(maxICs,maxICTs),ePot_IC(maxICs,maxICTs),&
		eBond_IC(maxICs,maxICTs),eVdw_IC(maxICs,maxICTs),eIntraVdw_IC(maxICs,maxICTs), &
		simTime_IC(maxICs,maxICTs), eqTime_IC(maxICs,maxICTs)
	integer :: N(15),Npick(50),Npick_vir(50),Nfile(50),N_IT(50),N_IC(maxICs,maxICTs),N_IT_vr(50),N_IT2_vr(50)
	integer :: convergeStatus(maxICs)
	double precision :: Zmin1OverRho_IT(0:15),aDep_IT(0:15),uDepT_IT(15),ThousandOverT_IT(15),aDep_IT2(0:15)
	double precision :: Zmin1OverRho_IC(maxICs,maxICTs),aDep_IC(maxICs,maxICTs),uDepT_IC(maxICs,maxICTs), &
			ThousandOverT_IC(maxICs,maxICTs)
	double precision :: multi_IT(15), multi_IC(maxICs,maxICTs),MW
	double precision :: Tsat(maxICs),Zsat(maxICs),uDepTsat(maxICs),aDepSat(maxICs)
	double precision :: rhoV(MaxICs),rhoVp(MaxICs),rhoVpp(MaxICs),zLiq(MaxICs),Psat(MaxICs),Hvap(MaxICs),&
				PsatLnDev(MaxICs),HvapLnDev(MaxICs),PsatDip(MaxICs)
	double precision :: B2sat(MaxICs),B3sat(MaxICs),B4sat(MaxICs),B5sat(MaxICs),B6sat(MaxICs)
	double precision :: PsatRmsd,TsatLnDev(MaxICs),HvapDip(MaxICs),RhoLDip(MaxICs),RhoLLnDev(MaxICs),&
				dB2_dBeta(maxICs)
	double precision :: T_IT_calc(50),rho_IT_calc(50),rho_IC_calc(50),T_VR_calc(4)
	double precision :: rho_IT_calc_vr(15)

	real,dimension (3)::bmatrix
	real,dimension (3)::xmatrix
	real,dimension (3,3)::amatrix

	double precision,parameter :: zero=0.0

	character :: potentialName*20
	character (len=20), dimension(15) :: SiteTypeNames,SigOfSite(15),EpsOfSite(15),AOfSite(15)
	double precision :: sigma(15),epsilon(15),AorN(15)
	character :: dumString1*50,dumString2*50,String*50,StrHighestRho*50,StrHighestT*50,StrTcal1*50,StrTcal3*50,StrTcal5*50
	common parFile
 	INTEGER*4 getcwd 

	CHARACTER(300) :: Address,Directory,FolderName,myName
	CHARACTER(300) :: CASN,CNAM,FAM,FORM,INAM,COMP_NAME,SMIL,STRU,SYN

 	integer date_time(8)
	character*30 d(6)

	integer RunITITinpFormat

	RunITITinpFormat = 2
!	0 = Original RunITIC.inp (nItPts and nICs = 5 are read from file
!	1 = ITICinfo
!	2 = modified RunITIC.info (nItPts = 9, nICs = 5 are hardcoded)
!	3 = modified RunITIC.info (nItpts = 12, nICs = 10 are hardcoded) !TODO: design and add a pick3 option

	maxTolerance = 1.0d0

	isMoleculeUnknown = .false.
	isUdepFromEpotMinusSingle=.false.
	isUdepFromEpotMinusSingleN=.false.
	isRichUdep = .false.	
	isUdepReadFromFile=.false.
	isUdepkcalReadFromFile=.false.
	isCriticalNeeded = .true.

	isMixedLQ = .false.
	isMixedLQ2 = .true.

	isLT = .true.
	isQT = .false.

	isLU = .false.
	isQU = .true.

	isConvergencePathNeeded=.false.

	isLinearuDepT = .false.
	is3rdOrderPolZ = .false.

	isNist=.false. !SMR: was here
	isThereB2correlationFromLiterature = .false. 
	isThereB2ITHardCoded = .false.
	disableExtrapolation=.false.	!disableExtrapolation is used for ITIC testing via NIST data: 
				!false: extrapolation is done, true: exact NIST values of zLiq, Tsat, uDepSat, and aDepSat are used
	
	isB2FromDippr=.false.

	isB2Applied=.true.	
	isB3Applied=.false.
	isB4Applied=.false.
	isB5Applied=.false.
	isB6Applied=.false.
	
	call getarg(1,arg1)
	call getarg(2,arg2)
	call getarg(3,arg3)
	call getarg(4,arg4)

	if(trim(arg1).eq."man".OR.trim(arg1).eq."MAN") then
		write(*,*) "Manual:"
	stop
	endif

	CASN=arg1

	if(isMoleculeUnknown.eqv..false.) then
		call Dippr(CASN,"CASN",dum,dum,CASN)
		call Dippr(CASN,"CNAM",dum,dum,CNAM)
		call Dippr(CASN,"FAM",dum,dum,FAM)
		call Dippr(CASN,"FORM",dum,dum,FORM)
		call Dippr(CASN,"INAM",dum,dum,INAM)
		call Dippr(CASN,"NAME",dum,dum,COMP_NAME)
		call Dippr(CASN,"SMIL",dum,dum,SMIL)
		call Dippr(CASN,"STRU",dum,dum,STRU)
		call Dippr(CASN,"SYN",dum,dum,SYN)

		call Dippr(CASN,"TC",dum,TC,"K")
		call Dippr(CASN,"MW",dum,MW,"g|mol")
		call Dippr(CASN,"PC",dum,PC,"Mpa")
		call Dippr(CASN,"VC",dum,VC,"cm^3|gm")
		!call Dippr(CASN,"ZC",dum,ZC,"1")
		!call Dippr(CASN,"TPT",dum,TPT,"K")

	else
		write(*,*)"Molecule is unknown!"
		write(*,*)"Enter critical temperature (K):"
		!read(*,*)TC != 1100.00
		TC = 1100.00
		write(*,*)"Enter molecular weight (g/mol):"
		!read(*,*)MW != 360.49024
		MW = 360.49024
		PC = 0.0
		VC = 0.0
		COMP_NAME=""
		INAM=""
		SMIL=""
		STRU=""
		SYN=""
		SYN=""
		FAM=""
		CNAM=""
		FORM=""
	endif

	if(trim(arg2).eq."pick".OR.trim(arg2).eq."PICK") then
		write(*,*) "Pick option was selected:"
		write(*,*)
		call Dippr(CASN,"TC",dum,TC,"K")
		call MaxMinT(CASN,"LDN",Tmin,Tmax)
		!write(*,*) Tmin/TC,Tmax/TC
		!write(*,*) Tmin,Tmax

		write(*,*) "Do you want to choose IT temperature and the density of highest IC manually?"
		read(*,*) yesOrno
		if(yesOrNo .eq. "yes" .Or. yesOrNo .eq. "YES") then
			write(*,*) "Enter isotherm T and density of highest IC:"
			read(*,*) HighestT,highestRho
		elseif(yesOrNo .eq. "no" .Or. yesOrNo .eq. "NO") then
			write(*,*) "Enter isotherm Tr and minimum Tr on binodal:"
			read(*,*) HighestTr,TrSatHighestIC
			HighestT = HighestTr * TC
			TSatHighestIC = TrSatHighestIC * TC
			call Dippr(CASN,"LDN",TSatHighestIC,highestRho,"gm|cm^3")
		else
			write(*,*) "Invalid answer. Try again!"
			stop
		endif
		write(*,*) "Enter # of isochores, and # of virial points:"
		read(*,*) nICs,nItVir
		write(*,*) "Enter # of molecules:"
		read(*,*) Nread

		nItPts=9	
		!nICs=5
		!nItVir=3
		iFirstIcPt=nItPts-nICs+1

		rho_IT_calc(9)=highestRho
		rho_increment=highestRho/7.0
		rho_IT_calc(1)=rho_increment
		rho_IT_calc(2)=rho_IT_calc(1)+rho_increment
		rho_IT_calc(3)=rho_IT_calc(2)+rho_increment
		rho_IT_calc(4)=rho_IT_calc(3)+rho_increment
		rho_IT_calc(5)=rho_IT_calc(4)+rho_increment
		rho_IT_calc(6)=rho_IT_calc(5)+rho_increment*0.5
		rho_IT_calc(7)=rho_IT_calc(6)+rho_increment*0.5
		rho_IT_calc(8)=rho_IT_calc(7)+rho_increment*0.5
		do i=1,nItVir
			rho_IT_calc_vr(i)=highestRho/(i+1)/7
			Npick_vir(i)=4*Nread
		enddo

		do i=iFirstIcPt,nItPts
			rho_IC_calc(i)=rho_IT_calc(i)
		enddo

	 	do i=iFirstIcPt,nItPts
			call DipprTfinder(CASN,"LDN",T_IC_calc(i,1),rho_IC_calc(i),"gm|cm^3")
			rec_T_increment=(1000.0/T_IC_calc(i,1)-1000.0/HighestT)/2.0
			do j=2,3
				T_IC_calc(i,j)=1000.0/(1000.0/T_IC_calc(i,1)-(j-1)*rec_T_increment)
			enddo
		enddo

		do i=1,nItPts
			T_IT_calc(i)=HighestT
			if(i .le. 3) then
				Npick(i)=4*Nread
			else
				Npick(i)=Nread
			endif
		enddo

		write(*,*)
		!write(*,'(A,A)')"Folder Name: ",trim(FolderName)
		!write(*,*)
		!write(*,'(A12,A50)')"Address:",trim(Address)
		!write(*,'(A)')trim(d(1))
		write(*,'(A5,3x,A)')"CASN:",trim(CASN)
		write(*,'(A5,3x,A)')"CNAM:",trim(CNAM)
		write(*,'(A5,3x,A)')"FAM:",trim(FAM)
		write(*,'(A5,3x,A)')"FORM:",trim(FORM)
		write(*,'(A5,3x,A)')"INAM:",trim(INAM)
		write(*,'(A5,3x,A)')"NAME:",trim(COMP_NAME)
		write(*,'(A5,3x,A)')"SMIL:",trim(SMIL)
		write(*,'(A5,3x,A)')"STRU:",trim(STRU)
		!write(*,'(A5,3x,A)')"SYN",trim(SYN)
		write(*,*)
		write(*,'(A5,F12.5,1x,A7)') "MW:",MW !,"(g/mol)"
		write(*,'(A5,F12.5,1x,A7)') "TC:",TC !,"(K)"
		write(*,'(A5,F12.5,1x,A7)') "PC:",PC !,"(Mpa)"
		write(*,'(A5,F12.5,1x,A7)') "RHOC:",1.d0/VC !,"(g/ml)"

		write(*,*)
		write(*,'(A9,1x,15(F8.2))')"T_IT:",HighestT
		write(*,'(A9,1x,15(I8))')"N_IT:",nItPts
		write(*,'(A9,1x,15(F8.4))')"RHO_IT:",(rho_IT_calc(j),j=1,nItPts)
		write(*,'(A9,1x,15(I8))')"NMOL:",(Npick(j),j=1,nItPts)
		write(*,*)
		write(*,'(A9,1x,15(F8.4))')"RHO_HIGH:",highestRho
		write(*,'(A9,1x,15(I8))')"N_IC:",nICs
		write(*,'(A9,1x,15(F8.4))')"RHO_IC:",(rho_IC_calc(j),j=iFirstIcPt,nItPts)
		icount=0
		do i=iFirstIcPt,nItPts
			icount=icount+1
			write(*,'(A7,I1,A,1x,15F8.2)') "T_IC",icount,":",T_IC_calc(i,1),T_IC_calc(i,2)
		enddo
		write(*,*)
		write(*,'(A9,1x,15(I8))')"N_VR:",nItVir
		write(*,'(A9,1x,15(F8.4))')"RHO_VR:",(rho_IT_calc_vr(j),j=1,nItVir)
		write(*,'(A9,1x,15(I8))')"NMOL_VR:",(Npick_vir(j),j=1,nItVir)
		write(*,*)

		open(87,file="RunITIC.inp")
		write(87,*)
		write(87,'(A5,3x,A)')"CASN:",trim(CASN)
		write(87,'(A5,3x,A)')"CNAM:",trim(CNAM)
		write(87,'(A5,3x,A)')"FAM:",trim(FAM)
		write(87,'(A5,3x,A)')"FORM:",trim(FORM)
		write(87,'(A5,3x,A)')"INAM:",trim(INAM)
		write(87,'(A5,3x,A)')"NAME:",trim(COMP_NAME)
		write(87,'(A5,3x,A)')"SMIL:",trim(SMIL)
		write(87,'(A5,3x,A)')"STRU:",trim(STRU)
		write(87,*)
		write(87,'(A5,F12.5,1x,A7)') "MW:",MW !,"(g/mol)"
		write(87,'(A5,F12.5,1x,A7)') "TC:",TC !,"(K)"
		write(87,'(A5,F12.5,1x,A7)') "PC:",PC !,"(Mpa)"
		write(87,'(A5,F12.5,1x,A7)') "RHOC:",1.d0/VC !,"(g/ml)"
		write(87,*)
		write(87,'(A9,1x,15(F8.2))')"T_IT:",HighestT
		write(87,'(A9,1x,15(I8))')"N_IT:",nItPts
		write(87,'(A9,1x,15(F8.4))')"RHO_IT:",(rho_IT_calc(j),j=1,nItPts)
		write(87,'(A9,1x,15(I8))')"NMOL:",(Npick(j),j=1,nItPts)
		write(87,*)
		write(87,'(A9,1x,15(F8.4))')"RHO_HIGH:",highestRho
		write(87,'(A9,1x,15(I8))')"N_IC:",nICs
		write(87,'(A9,1x,15(F8.4))')"RHO_IC:",(rho_IC_calc(j),j=iFirstIcPt,nItPts)
		icount=0
		do i=iFirstIcPt,nItPts
			icount=icount+1
			write(87,'(A7,I1,A,1x,15F8.2)') "T_IC",icount,":",T_IC_calc(i,1),T_IC_calc(i,2)
		enddo
		write(87,*)
		write(87,'(A9,1x,15(I8))')"N_VR:",nItVir
		write(87,'(A9,1x,15(F8.4))')"RHO_VR:",(rho_IT_calc_vr(j),j=1,nItVir)
		write(87,'(A9,1x,15(I8))')"NMOL_VR:",(Npick_vir(j),j=1,nItVir)
		write(87,*)
		close(87)

		stop
	elseif(trim(arg2).eq."pick2".OR.trim(arg2).eq."PICK2") then
		write(*,*) "Pick option was selected:"
		write(*,*)
		call Dippr(CASN,"TC",dum,TC,"K")
		call MaxMinT(CASN,"LDN",Tmin,Tmax)
		write(*,*) "Tr min,max=",Tmin/TC,Tmax/TC
		write(*,*) "T min,max",Tmin,Tmax

		write(*,*) "Do you want to choose IT temperature and the density of highest IC manually?"
		read(*,*) yesOrno
		if(yesOrNo .eq. "yes" .Or. yesOrNo .eq. "YES") then
			write(*,*) "Enter isotherm T and density of highest IC:"
			read(*,*) HighestT,highestRho
		!HighestT = 600
		!highestRho = 0.7
		elseif(yesOrNo .eq. "no" .Or. yesOrNo .eq. "NO") then
			write(*,*) "Enter isotherm Tr and minimum Tr on binodal:"
			read(*,*) HighestTr,TrSatHighestIC
			HighestT = HighestTr * TC
			TSatHighestIC = TrSatHighestIC * TC
			call Dippr(CASN,"LDN",TSatHighestIC,highestRho,"gm|cm^3")
		else
			write(*,*) "Invalid answer. Try again!"
			stop
		endif
		!write(*,*) "Enter # of isochores "
		!read(*,*) nICs
		write(*,*) "Enter # of molecules:"
		read(*,*) Nread
		!Nread = 600
		nItPts=9	
		nICs=5
		nItVir=3
		iFirstIcPt=nItPts-nICs+1

		rho_IT_calc(9)=highestRho
		rho_increment=highestRho/7.0
		rho_IT_calc(1)=rho_increment
		rho_IT_calc(2)=rho_IT_calc(1)+rho_increment
		rho_IT_calc(3)=rho_IT_calc(2)+rho_increment
		rho_IT_calc(4)=rho_IT_calc(3)+rho_increment
		rho_IT_calc(5)=rho_IT_calc(4)+rho_increment

		rho_IT_calc(6)=rho_IT_calc(5)+rho_increment*0.5
		rho_IT_calc(7)=rho_IT_calc(6)+rho_increment*0.5
		rho_IT_calc(8)=rho_IT_calc(7)+rho_increment*0.5
		do i=1,nItVir
			rho_IT_calc_vr(i)=highestRho/(i+1)/7
			Npick_vir(i)=4*Nread
		enddo

		do i=iFirstIcPt,nItPts
			rho_IC_calc(i)=rho_IT_calc(i)
		enddo

	 	do i=iFirstIcPt,nItPts
			call DipprTfinder(CASN,"LDN",T_IC_calc(i,1),rho_IC_calc(i),"gm|cm^3")
			rec_T_increment=(1000.0/T_IC_calc(i,1)-1000.0/HighestT)/2.0
			do j=2,3
				T_IC_calc(i,j)=1000.0/(1000.0/T_IC_calc(i,1)-(j-1)*rec_T_increment)
			enddo
		enddo

		do i=1,nItPts
			T_IT_calc(i)=HighestT
			if(i .le. 1) then
				Npick(i)=4*Nread
			else
				Npick(i)=Nread
			endif
		enddo

		write(*,*)
		write(*,'(A5,3x,A)')"CASN:",trim(CASN)
		write(*,'(A5,3x,A)')"CNAM:",trim(CNAM)
		write(*,'(A5,3x,A)')"FAM:",trim(FAM)
		write(*,'(A5,3x,A)')"FORM:",trim(FORM)
		write(*,'(A5,3x,A)')"INAM:",trim(INAM)
		write(*,'(A5,3x,A)')"NAME:",trim(COMP_NAME)
		write(*,'(A5,3x,A)')"SMIL:",trim(SMIL)
		write(*,'(A5,3x,A)')"STRU:",trim(STRU)
		!write(*,'(A5,3x,A)')"SYN",trim(SYN)
		write(*,*)
		write(*,'(A5,F12.5,1x,A7)') "MW:",MW !,"(g/mol)"
		write(*,'(A5,F12.5,1x,A7)') "TC:",TC !,"(K)"
		write(*,'(A5,F12.5,1x,A7)') "PC:",PC !,"(Mpa)"
		write(*,'(A5,F12.5,1x,A7)') "RHOC:",1.d0/VC !,"(g/ml)"
		write(*,*)
		write(*,'(A9,1x,15(F8.4))')"RHO_HIGH:",highestRho
		write(*,'(A9,1x,15(F8.2))')"T_HIGH:",HighestT
		write(*,*)
		write(*,*) "Isotherms:"
		write(*,*)
		write(*,'(A9,1x,15(F8.2))')"T_IT:",HighestT,TC*0.9
		write(*,*)
		write(*,'(A9,1x,15(F8.4))')"RHO_IT1:",(rho_IT_calc_vr(j),j=3,1,-1),(rho_IT_calc(j),j=1,nItPts)
		write(*,'(A9,1x,15(F8.4))')"RHO_IT2:",(rho_IT_calc_vr(j),j=3,1,-1),rho_IT_calc(1)
		write(*,*)
		write(*,'(A9,1x,15(I8))')"NMOL_IT1:",(Npick_vir(j),j=1,nItVir),(Npick(j),j=1,nItPts)
		write(*,'(A9,1x,15(I8))')"NMOL_IT2:",(Npick_vir(j),j=1,nItVir),Npick(1)
		write(*,*)
		write(*,*) "Isochores:"
		write(*,*)
		write(*,'(A9,1x,15(F8.4))')"RHO_IC:",(rho_IC_calc(j),j=iFirstIcPt,nItPts)
		write(*,*)
		icount=0
		do i=iFirstIcPt,nItPts
			icount=icount+1
			write(*,'(A7,I1,A,1x,15F8.2)') "T_IC",icount,":",T_IC_calc(i,1),T_IC_calc(i,2)
		enddo
		icount=0
		write(*,*)
		do i=iFirstIcPt,nItPts
			icount=icount+1
			write(*,'(A7,I1,A,1x,15(I8))')"NMOL_IC",icount,":",Nread,Nread
		enddo


		open(87,file="RunITIC.inp")
		write(87,*)
		write(87,'(A5,3x,A)')"CASN:",trim(CASN)
		write(87,'(A5,3x,A)')"CNAM:",trim(CNAM)
		write(87,'(A5,3x,A)')"FAM:",trim(FAM)
		write(87,'(A5,3x,A)')"FORM:",trim(FORM)
		write(87,'(A5,3x,A)')"INAM:",trim(INAM)
		write(87,'(A5,3x,A)')"NAME:",trim(COMP_NAME)
		write(87,'(A5,3x,A)')"SMIL:",trim(SMIL)
		write(87,'(A5,3x,A)')"STRU:",trim(STRU)
		!write(87,'(A5,3x,A)')"SYN",trim(SYN)
		write(87,*)
		write(87,'(A5,F12.5,1x,A7)') "MW:",MW !,"(g/mol)"
		write(87,'(A5,F12.5,1x,A7)') "TC:",TC !,"(K)"
		write(87,'(A5,F12.5,1x,A7)') "PC:",PC !,"(Mpa)"
		write(87,'(A5,F12.5,1x,A7)') "RHOC:",1.d0/VC !,"(g/ml)"
		write(87,*)
		write(87,'(A9,1x,15(F8.4))')"RHO_HIGH:",highestRho
		write(87,'(A9,1x,15(F8.2))')"T_HIGH:",HighestT
		write(87,*)
		write(87,*) "Isotherms:"
		write(87,*)
		write(87,'(A9,1x,15(F8.2))')"T_IT:",HighestT,TC*0.9
		write(87,*)
		write(87,'(A9,1x,15(F8.4))')"RHO_IT1:",(rho_IT_calc_vr(j),j=3,1,-1),(rho_IT_calc(j),j=1,nItPts)
		write(87,'(A9,1x,15(F8.4))')"RHO_IT2:",(rho_IT_calc_vr(j),j=3,1,-1),rho_IT_calc(1)
		write(87,*)
		write(87,'(A9,1x,15(I8))')"NMOL_IT1:",(Npick_vir(j),j=1,nItVir),(Npick(j),j=1,nItPts)
		write(87,'(A9,1x,15(I8))')"NMOL_IT2:",(Npick_vir(j),j=1,nItVir),Npick(1)
		write(87,*)
		write(87,*) "Isochores:"
		write(87,*)
		write(87,'(A9,1x,15(F8.4))')"RHO_IC:",(rho_IC_calc(j),j=iFirstIcPt,nItPts)
		write(87,*)
		icount=0
		do i=iFirstIcPt,nItPts
			icount=icount+1
			write(87,'(A7,I1,A,1x,15F8.2)') "T_IC",icount,":",T_IC_calc(i,1),T_IC_calc(i,2)
		enddo
		icount=0
		write(87,*)
		do i=iFirstIcPt,nItPts
			icount=icount+1
			write(87,'(A7,I1,A,1x,15(I8))')"NMOL_IC",icount,":",Nread,Nread
		enddo
		close(87)

		stop
	endif
	LammpsRdrOut=arg2
	RunITICinp=arg3
	parFile=arg4
	write(*,*)'Using: ',TRIM(CASN),' ',TRIM(LammpsRdrOut),' ',TRIM(RunITICinp),' ',TRIM(parFile)
	write(*,*)'Compound is: ',TRIM(COMP_NAME)
	call date_and_time(d(1), d(2), d(3), date_time) 

	if(parFile .ne. "")then
	open(21,file=parFile)
		read(21,*)dumString,potentialName
		read(21,*)dumString,nSiteTypes
		read(21,*)dumString,(SiteTypeNames(j),j=1,nSiteTypes)
		read(21,*)dumString,(sigma(j),j=1,nSiteTypes)
		read(21,*)dumString,(epsilon(j),j=1,nSiteTypes)
		read(21,*)dumString,(AorN(j),j=1,nSiteTypes)
		read(21,*)dumString,rWidth
		read(21,*)dumString,rInit
	close(21)
	endif
	open(2231,file=RunITICinp)
	if(RunITITinpFormat .eq. 0)then
		do loopline=1,100	
			read(2231,*,ioStat=ioErr) dumString1,dumString2
			!write(*,*) dumString1,dumString2
			String = trim(dumString1)
			if(String.eq."RHO_HIGH:") then
				read(dumString2,*,iostat=ioErr)highestRho
			elseif(String.eq."T_IT:") then
				read(dumString2,*,iostat=ioErr)HighestT
			elseif(String.eq."N_IT:") then
				read(dumString2,*,iostat=ioErr)nItPts
			elseif(String.eq."N_IC:") then
				read(dumString2,*,iostat=ioErr)nICs
			elseif(String.eq."T_IC1:") then
				write(*,*)
				iFirstIcPt=nItPts-nICs+1
				read(dumString2,*,iostat=ioErr)T_IC_calc(iFirstIcPt,1)
				do i=iFirstIcPt+1,nItPts
					read(2231,*,ioStat=ioErr) dumString1,dumString2
					read(dumString2,*,iostat=ioErr)T_IC_calc(i,1)
				enddo
			endif

		end do
	elseif(RunITITinpFormat .eq. 1)then
		nItPts = 9
		nICs = 3
		iFirstIcPt = 7 !nItPts-nICs+1

		read(2231,*,ioStat=ioErr) dumString1
		read(dumString1,*,iostat=ioErr)HighestT

		read(2231,*,ioStat=ioErr)

		read(2231,*,ioStat=ioErr) dumString1
		read(dumString1,*,iostat=ioErr) highestRho


		read(2231,*,ioStat=ioErr) dumString1,dumString2
		read(dumString2,*,iostat=ioErr) T_IC_calc(9,1)

		read(2231,*,ioStat=ioErr) dumString1,dumString2
		read(dumString2,*,iostat=ioErr) T_IC_calc(8,1)

		read(2231,*,ioStat=ioErr) dumString1,dumString2
		read(dumString2,*,iostat=ioErr) T_IC_calc(7,1)

	elseif(RunITITinpFormat .eq. 2)then
		nItPts = 9
		nICs = 5
		do loopline=1,100	
			read(2231,*,ioStat=ioErr) dumString1,dumString2
			!write(*,*) dumString1,dumString2
			String = trim(dumString1)
			if(String.eq."RHO_HIGH:") then
				read(dumString2,*,iostat=ioErr)highestRho
			elseif(String.eq."T_HIGH:") then
				read(dumString2,*,iostat=ioErr)HighestT
!			elseif(String.eq."N_IT:") then
!				read(dumString2,*,iostat=ioErr)nItPts
!			elseif(String.eq."N_IC:") then
!				read(dumString2,*,iostat=ioErr)nICs
			elseif(String.eq."T_IC1:") then
				write(*,*)
				iFirstIcPt=nItPts-nICs+1
				read(dumString2,*,iostat=ioErr)T_IC_calc(iFirstIcPt,1)
				do i=iFirstIcPt+1,nItPts
					read(2231,*,ioStat=ioErr) dumString1,dumString2
					read(dumString2,*,iostat=ioErr)T_IC_calc(i,1)
				enddo
			endif

		end do
	elseif(RunITITinpFormat .eq. 3)then
		nItPts = 11
		nICs = 9
		do loopline=1,100	
			read(2231,*,ioStat=ioErr) dumString1,dumString2
			!write(*,*) dumString1,dumString2
			String = trim(dumString1)
			if(String.eq."RHO_HIGH:") then
				read(dumString2,*,iostat=ioErr)highestRho
			elseif(String.eq."T_HIGH:") then
				read(dumString2,*,iostat=ioErr)HighestT
!			elseif(String.eq."N_IT:") then
!				read(dumString2,*,iostat=ioErr)nItPts
!			elseif(String.eq."N_IC:") then
!				read(dumString2,*,iostat=ioErr)nICs
			elseif(String.eq."T_IC1:") then
				write(*,*)
				iFirstIcPt=nItPts-nICs+1
				read(dumString2,*,iostat=ioErr)T_IC_calc(iFirstIcPt,1)
				do i=iFirstIcPt+1,nItPts
					read(2231,*,ioStat=ioErr) dumString1,dumString2
					read(dumString2,*,iostat=ioErr)T_IC_calc(i,1)
				enddo
			endif

		end do
	endif
	close(2231)	


	!write(*,*)nItPts,iFirstIcPt,highestRho,HighestT,nICs,(T_IC_calc(i,1),i=iFirstIcPt,nItPts)

	if(nItPts .eq. 9) then
		rho_IT_calc(9)=highestRho
		rho_increment=highestRho/7.0
		rho_IT_calc(1)=rho_increment
		rho_IT_calc(2)=rho_IT_calc(1)+rho_increment
		rho_IT_calc(3)=rho_IT_calc(2)+rho_increment
		rho_IT_calc(4)=rho_IT_calc(3)+rho_increment
		rho_IT_calc(5)=rho_IT_calc(4)+rho_increment
		rho_IT_calc(6)=rho_IT_calc(5)+rho_increment*0.5
		rho_IT_calc(7)=rho_IT_calc(6)+rho_increment*0.5
		rho_IT_calc(8)=rho_IT_calc(7)+rho_increment*0.5
		
		rho_IT_calc_vr(4)=highestRho/7.0
		rho_IT_calc_vr(3)=highestRho/14.0
		rho_IT_calc_vr(2)=highestRho/21.0
		rho_IT_calc_vr(1)=highestRho/28.0


	elseif (nItPts .eq. 11) then
		rho_IT_calc(11)=highestRho
		rho_increment=highestRho/7.0
		rho_IT_calc(1)=rho_increment
		rho_IT_calc(2)=rho_IT_calc(1)+rho_increment*1.0
		rho_IT_calc(3)=rho_IT_calc(2)+rho_increment*1.0
		rho_IT_calc(4)=rho_IT_calc(3)+rho_increment*0.5
		rho_IT_calc(5)=rho_IT_calc(4)+rho_increment*0.5
		rho_IT_calc(6)=rho_IT_calc(5)+rho_increment*0.5
		rho_IT_calc(7)=rho_IT_calc(6)+rho_increment*0.5
		rho_IT_calc(8)=rho_IT_calc(7)+rho_increment*0.5
		rho_IT_calc(9)=rho_IT_calc(8)+rho_increment*0.5
		rho_IT_calc(10)=rho_IT_calc(9)+rho_increment*0.5

		rho_IT_calc_vr(4)=highestRho/7.0
		rho_IT_calc_vr(3)=highestRho/14.0
		rho_IT_calc_vr(2)=highestRho/21.0
		rho_IT_calc_vr(1)=highestRho/28.0

	endif

	 do i=iFirstIcPt,nItPts
		rec_T_increment=(1000.0/T_IC_calc(i,1)-1000.0/HighestT)/(nPointsOnIC-1)
		do j=2,nPointsOnIC
			T_IC_calc(i,j)=1000.0/(1000.0/T_IC_calc(i,1)-(j-1)*rec_T_increment)
		enddo
	enddo

	do i=iFirstIcPt,nItPts
		rho_IC_calc(i)=rho_IT_calc(i)
	enddo

	do i=1,nItPts
		T_IT_calc(i)=HighestT
	enddo

	!fix here: nees to be smart enough to recognize any of these subcritical T's to be the subcritical isothermal temperature
	T_VR_calc(1)=TC*0.80
	T_VR_calc(2)=TC*0.85
	T_VR_calc(3)=TC*0.90
	T_VR_calc(4)=TC*0.95

	SubCritReducedTemp = 0.9

	write(*,*)
	write(*,*)'===============================Reading From Simulator Output====================================='
	write(*,*)
	write(*,'(A2,1x,A9,1x,A9,1x,3(A9,1x),6(A15,1x),A6)')'i','T(K)','rho(g/ml)','P(atm)','Z','Zstd','ePot(kcal/mol)','eMol(kcal/mol)','&
				eVdw(kcal/mol)','IVdw(kcal/mol)','RunTime(ns)','EqTime(ns)','nMolec'

	open(4321,file=LammpsRdrOut)
	read(4321,*)
	!ioErr=0
	do i=1,nMaxData	

		read(4321,*,ioStat=ioErr) Tfile(i),rhofile(i),Pfile(i),Zfile(i),Zstdfile(i),ePotfile(i), &
				eBondfile(i),eVdwfile(i),eIntraVdwfile(i),simTimefile(i),eqTimefile(i),Nfile(i)
		if(ioErr == -1)then !End of file reached
			!iEnd=1
			!print*,'End of File reached'
			nData=i-1
			exit
		endif
		write(*,'(I2,1x,f9.2,1x,f9.5,1x,3(f9.3,1x),4(f15.3,1x),2(f15.1,1x),I6)') &
				i,Tfile(i),rhofile(i),Pfile(i),Zfile(i),Zstdfile(i),ePotfile(i), &
				eBondfile(i),eVdwfile(i),eIntraVdwfile(i),simTimefile(i),eqTimefile(i),Nfile(i)


	enddo
	close(4321)

	write(*,*)
	write(*,*)'===============================Splitting Data into IT and IC Arrays====================================='
	write(*,*)
	do i=1,nData
		do j=1,nItPts
			tolerance=(abs(Tfile(i)-T_IT_calc(j))/Tfile(i)*100.0+abs(rhofile(i)-rho_IT_calc(j))/rhofile(i)*100.0)
			!write(*,*)tolerance
			!pause
			if(tolerance .lt. maxTolerance) then

			
				T_IT(j)=Tfile(i)
				rho_IT(j)=rhofile(i)
				P_IT(j)=Pfile(i)
				Z_IT(j)=Zfile(i)
				Zstd_IT(j)=Zstdfile(i)
				ePot_IT(j)=ePotfile(i)
				eBond_IT(j)=eBondfile(i)
				eVdw_IT(j)=eVdwfile(i)
				eIntraVdw_IT(j)=eIntraVdwfile(i)
				simTime_IT(j)=simTimefile(i) 
				eqTime_IT(j)=eqTimefile(i)
				N_IT(j)=Nfile(i)
			exit
			endif
		
		enddo
	enddo

	do i=1,nData
		do j=iFirstIcPt,nItPts
			do k=1,nPointsOnIC
				tolerance=(abs(Tfile(i)-T_IC_calc(j,k))/Tfile(i)*100.0+abs(rhofile(i)-rho_IC_calc(j))/rhofile(i)*100.0)
				if(tolerance .lt. maxTolerance) then
					T_IC(j,k)=Tfile(i)
					rho_IC(j)=rhofile(i)
					P_IC(j,k)=Pfile(i)
					Z_IC(j,k)=Zfile(i)
					Zstd_IC(j,k)=Zstdfile(i)
					ePot_IC(j,k)=ePotfile(i)
					eBond_IC(j,k)=eBondfile(i)
					eVdw_IC(j,k)=eVdwfile(i)
					eIntraVdw_IC(j,k)=eIntraVdwfile(i)
					simTime_IC(j,k)=simTimefile(i)
					eqTime_IC(j,k)=eqTimefile(i)
					N_IC(j,k)=Nfile(i)
				exit
				endif
			enddo
		enddo
	enddo

	do i=1,nData
		do j=1,4
			tolerance=(abs(Tfile(i)-HighestT)/Tfile(i)*100.0+abs(rhofile(i)-rho_IT_calc_vr(j))/rhofile(i)*100.0)
			!write(*,*)tolerance
			!pause
			if(tolerance .lt. maxTolerance) then

			
				T_IT_vr(j)=Tfile(i)

				rho_IT_vr(j)=rhofile(i)
				P_IT_vr(j)=Pfile(i)
				Z_IT_vr(j)=Zfile(i)
				Zstd_IT_vr(j)=Zstdfile(i)
				ePot_IT_vr(j)=ePotfile(i)
				eBond_IT_vr(j)=eBondfile(i)
				eVdw_IT_vr(j)=eVdwfile(i)
				eIntraVdw_IT_vr(j)=eIntraVdwfile(i)
				simTime_IT_vr(j)=simTimefile(i) 
				eqTime_IT_vr(j)=eqTimefile(i)
				N_IT_vr(j)=Nfile(i)
			exit
			endif
		
		enddo
	enddo

	do i=1,nData
		do j=1,4
			tolerance=(abs(Tfile(i)-TC*SubCritReducedTemp)/Tfile(i)*100.0+abs(rhofile(i)-rho_IT_calc_vr(j))/rhofile(i)*100.0)
			!write(*,*)tolerance
			!pause
			if(tolerance .lt. maxTolerance) then

				T_IT2_vr(j)=Tfile(i)

				rho_IT2_vr(j)=rhofile(i)
				P_IT2_vr(j)=Pfile(i)
				Z_IT2_vr(j)=Zfile(i)
				Zstd_IT2_vr(j)=Zstdfile(i)
				ePot_IT2_vr(j)=ePotfile(i)
				eBond_IT2_vr(j)=eBondfile(i)
				eVdw_IT2_vr(j)=eVdwfile(i)
				eIntraVdw_IT2_vr(j)=eIntraVdwfile(i)
				simTime_IT2_vr(j)=simTimefile(i) 
				eqTime_IT2_vr(j)=eqTimefile(i)
				N_IT2_vr(j)=Nfile(i)
			exit
			endif
		
		enddo
	enddo

	rho1dif = abs(rho_IT_vr(1)-rho_IT_calc_vr(1))/rho_IT_calc_vr(1)*100
	rho2dif = abs(rho_IT_vr(2)-rho_IT_calc_vr(2))/rho_IT_calc_vr(2)*100
	rho3dif = abs(rho_IT_vr(3)-rho_IT_calc_vr(3))/rho_IT_calc_vr(3)*100
	if ( rho1dif .le. 1.0 .AND. rho2dif .le. 1.0 .AND. rho3dif .le. 1.0) then
		doesVirialCalcITpointsExist = .true. 
	else
		doesVirialCalcITpointsExist = .false. 
	endif

	rho1dif2 = abs(rho_IT2_vr(1)-rho_IT_calc_vr(1))/rho_IT_calc_vr(1)*100
	rho2dif2 = abs(rho_IT2_vr(2)-rho_IT_calc_vr(2))/rho_IT_calc_vr(2)*100
	rho3dif2 = abs(rho_IT2_vr(3)-rho_IT_calc_vr(3))/rho_IT_calc_vr(3)*100
	if ( rho1dif2 .le. 1.0 .AND. rho2dif2 .le. 1.0 .AND. rho3dif2 .le. 1.0) then
		doesVirialCalcIT2pointsExist = .true. 
	else
		doesVirialCalcIT2pointsExist = .false. 
	endif


	write(*,*) "Isothermic Points"
	write(*,'(A2,1x,A9,1x,A9,1x,3(A9,1x),6(A15,1x),A6)')'i','T(K)','rho(g/ml)','P(atm)','Z','Zstd','ePot(kcal/mol)','eMol(kcal/mol)','&
				eVdw(kcal/mol)','IVdw(kcal/mol)','RunTime(ns)','EqTime(ns)','nMolec'
	do i=1,nItPts

		multi_IT(i)=T_IT(i)*rho_IT(i)
		if(multi_IT(i) < 1e-11) then
			!isoThermErr=1
			write(*,'(A31,1x,I2,A6,1x,2F10.5)') "Warning: Data lacks row number",i,'T,rho:',T_IT_calc(i),rho_IT_calc(i)
			cycle
		endif
		write(*,'(I2,1x,f9.2,1x,f9.5,1x,3(f9.3,1x),4(f15.3,1x),2(f15.1,1x),I6)')&
		i,T_IT(i),rho_IT(i),P_IT(i),Z_IT(i),Zstd_IT(i),ePot_IT(i),eBond_IT(i),eVdw_IT(i),&
		eIntraVdw_IT(i),simTime_IT(i),eqTime_IT(i),N_IT(i)

	enddo

	do j=iFirstIcPt,nItPts
		write(*,*)
		write(*,'(A28,2x,I2)') "Isochoric Points on Isochore",j
		write(*,'(A2,1x,A9,1x,A9,1x,3(A9,1x),6(A15,1x),A6)')'i','T(K)','rho(g/ml)','P(atm)','Z','Zstd','ePot(kcal/mol)',&
				'eMol(kcal/mol)','&
				eVdw(kcal/mol)','IVdw(kcal/mol)','RunTime(ns)','EqTime(ns)','nMolec'
		do k=1,nPointsOnIC
			multi_IC(j,k)=T_IC(j,k)*rho_IC(j)
			if(multi_IC(j,k) < 1e-11) then
				!isoThermErr=1
				write(*,'(A31,1x,2I2,A6,1x,2F10.5)') "Warning: Data lacks row number",j,k,'T,rho:',T_IC_calc(j,k),rho_IC_calc(j)
				cycle
			endif
		write(*,'(I2,1x,f9.2,1x,f9.5,1x,3(f9.3,1x),4(f15.3,1x),2(f15.1,1x),I6)')&
		k,T_IC(j,k),rho_IC(j),P_IC(j,k),Z_IC(j,k),Zstd_IC(j,k),ePot_IC(j,k),eBond_IC(j,k),eVdw_IC(j,k),&
		eIntraVdw_IC(j,k),simTime_IC(j,k),eqTime_IC(j,k),N_IC(j,k)
		enddo
	enddo



if(doesVirialCalcITpointsExist) then
	write(*,*)
	write(*,*) "Supercritical Virial Calculation Points"
	write(*,'(A2,1x,A9,1x,A9,1x,3(A9,1x),6(A15,1x),A6)')'i','T(K)','rho(g/ml)','P(atm)','Z','Zstd','ePot(kcal/mol)','eMol(kcal/mol)','&
				eVdw(kcal/mol)','IVdw(kcal/mol)','RunTime(ns)','EqTime(ns)','nMolec'
	do i=1,4
		multi_IT(i)=T_IT_vr(i)*rho_IT_vr(i)
		if(multi_IT(i) < 1e-11) then
			!isoThermErr=1
			write(*,'(A31,1x,I2,A6,1x,2F10.5)') "Warning: Data lacks row number",i,'T,rho:',HighestT,rho_IT_calc_vr(i)
			cycle
		endif
		write(*,'(I2,1x,f9.2,1x,f9.5,1x,3(f9.3,1x),4(f15.3,1x),2(f15.1,1x),I6)')&
		i,T_IT_vr(i),rho_IT_vr(i),P_IT_vr(i),Z_IT_vr(i),Zstd_IT_vr(i),ePot_IT_vr(i),eBond_IT_vr(i),eVdw_IT_vr(i),&
		eIntraVdw_IT_vr(i),simTime_IT_vr(i),eqTime_IT_vr(i),N_IT_vr(i)

	enddo
endif

if(doesVirialCalcIT2pointsExist) then
	write(*,*)
	write(*,*) "Subcritical Virial Calculation  Points"
	write(*,'(A2,1x,A9,1x,A9,1x,3(A9,1x),6(A15,1x),A6)')'i','T(K)','rho(g/ml)','P(atm)','Z','Zstd','ePot(kcal/mol)','eMol(kcal/mol)','&
				eVdw(kcal/mol)','IVdw(kcal/mol)','RunTime(ns)','EqTime(ns)','nMolec'
	do i=1,4
		multi_IT(i)=T_IT2_vr(i)*rho_IT2_vr(i)
		if(multi_IT(i) < 1e-11) then
			!isoThermErr=1
			write(*,'(A31,1x,I2,A6,1x,2F10.5)') "Warning: Data lacks row number",i,'T,rho:',T_IT2_vr(i),rho_IT_calc_vr(i)
			cycle
		endif
		write(*,'(I2,1x,f9.2,1x,f9.5,1x,3(f9.3,1x),4(f15.3,1x),2(f15.1,1x),I6)')&
		i,T_IT2_vr(i),rho_IT2_vr(i),P_IT2_vr(i),Z_IT2_vr(i),Zstd_IT2_vr(i),ePot_IT2_vr(i),eBond_IT2_vr(i),eVdw_IT2_vr(i),&
		eIntraVdw_IT2_vr(i),simTime_IT2_vr(i),eqTime_IT2_vr(i),N_IT2_vr(i)

	enddo
endif

	do i=1,nItPts
		Zmin1OverRho_IT(i)=(Z_IT(i)-1.0)/rho_IT(i)
		uDepT_IT(i)=(ePot_IT(i)-eBond_IT(i)-eIntraVdw_IT(i))/1.987d0*1000.d0/N_IT(i)
		!uDepT_IT(i)=(ePot_IT(i))/1.987d0*1000.d0/N_IT(i)
		!uDepT_IT(i)=(ePot_IT(i)-eBond_IT(i))/1.987d0*1000.d0/N_IT(i)
		!uDepT_IT(i)=(ePot_IT(i)-eIntraVdw_IT(i))/1.987d0*1000.d0/N_IT(i)
		!uDepT_IT(i)=(eVdw_IT(i))/1.987d0*1000.d0/N_IT(i)
		if(isRichUdep)                uDepT_IT(i)=(ePot_IT(i))/1.987d0*1000.d0/N_IT(i)	!Based on Rich's inputfile
		if(isUdepReadFromFile)        uDepT_IT(i)=(ePot_IT(i))*T_IT(i)
		if(isUdepkcalReadFromFile)    uDepT_IT(i)=(ePot_IT(i)-eBond_IT(i))/1.987d0*1000.d0/N_IT(i)
		if(isUdepFromEpotMinusSingle) uDepT_IT(i)=(ePot_IT(i)-Zstd_IT(i)*N_IT(i))/1.987d0*1000.d0/N_IT(i)
		if(isUdepFromEpotMinusSingleN)uDepT_IT(i)=(ePot_IT(i)-Zstd_IT(i))/1.987d0*1000.d0/N_IT(i)
		ThousandOverT_IT(i)=1000.d0/T_IT(i)

	enddo
	do j=iFirstIcPt,nItPts
		do k=1,nPointsOnIC
			Zmin1OverRho_IC(j,k)=(Z_IC(j,k)-1.0)/rho_IC(j)
			uDepT_IC(j,k)=(ePot_IC(j,k)-eBond_IC(j,k)-eIntraVdw_IC(j,k))/1.987d0*1000.d0/N_IC(j,k)
			!uDepT_IC(j,k)=(ePot_IC(j,k))/1.987d0*1000.d0/N_IC(j,k)
			!uDepT_IC(j,k)=(ePot_IC(j,k)-eBond_IC(j,k))/1.987d0*1000.d0/N_IC(j,k)
			!uDepT_IC(j,k)=(ePot_IC(j,k)-eIntraVdw_IC(j,k))/1.987d0*1000.d0/N_IC(j,k)
			!uDepT_IC(j,k)=(eIntraVdw_IC(j,k))/1.987d0*1000.d0/N_IC(j,k)
			if(isRichUdep) uDepT_IC(j,k)=(ePot_IC(j,k))/1.987d0*1000.d0/N_IC(j,k)	!Based on Rich's inputfile
			if(isUdepReadFromFile) uDepT_IC(j,k)=(ePot_IC(j,k)-eBond_IC(j,k))*T_IC(j,k)
			if(isUdepkcalReadFromFile) uDepT_IC(j,k)=(ePot_IC(j,k))/1.987d0*1000.d0/N_IC(j,k)
			if(isUdepFromEpotMinusSingle) uDepT_IC(j,k)=(ePot_IC(j,k)-Zstd_IC(j,k)*N_IC(j,k))/1.987d0*1000.d0/N_IC(j,k)
			if(isUdepFromEpotMinusSingleN) uDepT_IC(j,k)=(ePot_IC(j,k)-Zstd_IC(j,k))/1.987d0*1000.d0/N_IC(j,k)
			ThousandOverT_IC(j,k)=1000.d0/T_IC(j,k)
		enddo
	enddo	


!========================================Determining B2 Correlation=====================================

	if(isMoleculeUnknown.eqv..false.) then
		call Dippr(CASN,"SVR",HighestT,B2atHighestT,"cm^3|gm")	!second virial coeff
	endif

	if(isThereB2ITHardCoded) then
		if(trim(CASN).eq."74-84-0") then
			B2atHighestT=-3.588	!Test of TraPPE-C2 with KofkeVirial
		elseif(trim(CASN).eq."111-65-9") then
		!===========TraPPE-C8 Kofke==========
			B2A=-7.4672	
			B2B=17.7516 	
			B2C=-25.9879	
			B2D=10.659
			Tr_rec_IT=TC/600.0
			B2atHighestT=B2A*Tr_rec_IT**3+B2B*Tr_rec_IT**2+B2C*Tr_rec_IT+B2D
		elseif(trim(CASN).eq."112-40-3") then
			B2atHighestT=-4.7983	!Test of TraPPE-C12 with KofkeVirial
		elseif(trim(CASN).eq."7732-18-5") then
			B2athighestT=-4.4483	!TIP4p linear regression
		elseif(trim(CASN).eq."106-97-8") then
			B2athighestT=-2.86	!TraPPE-C4
		endif
	endif

	write(*,*)
	write(*,*)"doesVirialCalcITpointsExist?",doesVirialCalcITpointsExist
	write(*,*)"doesVirialCalcIT2pointsExist?",doesVirialCalcIT2pointsExist

	if(doesVirialCalcITpointsExist) then
		Y1 = (Z_IT_vr(1) - 1.0)/rho_IT_vr(1)
		Y2 = (Z_IT_vr(2) - 1.0)/rho_IT_vr(2)
		Y3 = (Z_IT_vr(3) - 1.0)/rho_IT_vr(3)
		Y4 = (Z_IT_vr(4) - 1.0)/rho_IT_vr(4)

		X1 = rho_IT_vr(1)
		X2 = rho_IT_vr(2)
		X3 = rho_IT_vr(3)
		X4 = rho_IT_vr(4)

		call getInterceptSlope(X1,X2,X3,X4,Y1,Y2,Y3,Y4,B2atHighestT,B3atHighestT)
	endif

	if(doesVirialCalcITpointsExist .AND. doesVirialCalcIT2pointsExist) then

		Y1 = (Z_IT2_vr(1) - 1.0)/rho_IT2_vr(1)
		Y2 = (Z_IT2_vr(2) - 1.0)/rho_IT2_vr(2)
		Y3 = (Z_IT2_vr(3) - 1.0)/rho_IT2_vr(3)
		Y4 = (Z_IT2_vr(4) - 1.0)/rho_IT2_vr(4)

		X1 = rho_IT2_vr(1)
		X2 = rho_IT2_vr(2)
		X3 = rho_IT2_vr(3)
		X4 = rho_IT2_vr(4)

		call getInterceptSlope(X1,X2,X3,X4,Y1,Y2,Y3,Y4,B2atSubcriticalIT,B3atSubcriticalIT)

		do i=1,4
			!Zmin1OverRho_IT2(i)=(Z_IT2_vr(i)-1.0)/rho_IT2_vr(i)
			uDep_over_rho_vr(i)=(ePot_IT2_vr(i)-eBond_IT2_vr(i)-eIntraVdw_IT2_vr(i))/1.987d0*1000.d0/N_IT2_vr(i)/T_IT2_vr(i)/rho_IT2_vr(i)
			if(isRichUdep)then
				uDep_over_rho_vr(i)=(ePot_IT2_vr(i))/1.987d0*1000.d0/N_IT2_vr(i)/T_IT2_vr(i)/rho_IT2_vr(i)
			endif
			if(isUdepReadFromFile) uDep_over_rho_vr(i)=(ePot_IT2_vr(i))/rho_IT2_vr(i)
			!write(*,*)N_IT2_vr(i),T_IT2_vr(i),rho_IT2_vr(i),uDep_over_rho_vr(i)
		enddo

		Y1 = uDep_over_rho_vr(1)
		Y2 = uDep_over_rho_vr(2)
		Y3 = uDep_over_rho_vr(3)
		Y4 = uDep_over_rho_vr(4)

		X1 = rho_IT2_vr(1)
		X2 = rho_IT2_vr(2)
		X3 = rho_IT2_vr(3)
		X4 = rho_IT2_vr(4)

		call getInterceptSlope(X1,X2,X3,X4,Y1,Y2,Y3,Y4,uDepOverRhoVsRhoIntercept,uDepOverRhoVsRhoSlope)
		write(*,*)uDepOverRhoVsRhoIntercept,uDepOverRhoVsRhoSlope
		TofSubCriticalIT=TC*SubCritReducedTemp

		amatrix(1,1)=0.0
		amatrix(1,2)=1.0/HighestT - 1.0/TofSubCriticalIT
		amatrix(1,3)=1.0/HighestT**3 - 1.0/TofSubCriticalIT**3

		amatrix(2,1)=0.0
		amatrix(2,2)=1.0/TofSubCriticalIT
		amatrix(2,3)=3.0/TofSubCriticalIT**3

		amatrix(3,1)=1.0
		amatrix(3,2)=1.0/HighestT
		amatrix(3,3)=1.0/HighestT**3

		bmatrix(1)=B2atHighestT - B2atSubcriticalIT
		bmatrix(2)=uDepOverRhoVsRhoIntercept
		bmatrix(3)=B2atHighestT

		xmatrix(3)=(bmatrix(2)-amatrix(2,2)*bmatrix(1)/amatrix(1,2))/(amatrix(2,3)-amatrix(1,3)*amatrix(2,2)/amatrix(1,2))
		xmatrix(2)=bmatrix(1)/amatrix(1,2)-amatrix(1,3)/amatrix(1,2)*xmatrix(3)
		xmatrix(1)=bmatrix(3)-amatrix(3,2)*xmatrix(2)-amatrix(3,3)*xmatrix(3)

		!write(*,*)amatrix(1,1),amatrix(1,2),amatrix(1,3)
		!write(*,*)amatrix(2,1),amatrix(2,2),amatrix(2,3)
		!write(*,*)amatrix(3,1),amatrix(3,2),amatrix(3,3)
		write(*,*)
		write(*,*) "Virial A coef=",xmatrix(1)
		write(*,*) "Virial B coef=",xmatrix(2)
		write(*,*) "Virial C coef=",xmatrix(3)
		Acoef = xmatrix(1)
		Bcoef = xmatrix(2)
		Ccoef = xmatrix(3)
		B2atHighestT = Acoef + Bcoef/HighestT + Ccoef / HighestT**3
	endif

	if(isB2FromDippr) call Dippr(CASN,"SVR",HighestT,B2atHighestT,"cm^3|gm")	!second virial coeff

	B2ITfactor=1.00+0.00
	if((isNist .eqv. .true.) .AND. (doesVirialCalcITpointsExist .eqv. .false.)) then
		B2atHighestT=Zstd_IT(1) !SMR was here !-6.286700 !
	endif

	B2atHighestT=B2atHighestT*B2ITfactor

	write(*,'(A9,1x,2(F10.4,3x))')"B2_IT:",B2atHighestT,HighestT
	write(*,'(A9,1x,2(F10.4,3x))')"B2_IT2:",B2atSubcriticalIT,TofSubCriticalIT

!	VirialTreatmentApplied="No"
!	if(multi_IT(1)*multi_IT(2) .lt. 1e-11) then	!change it to only consider point 2 on IT to check if virial is needed
!		write(*,*) "Warning: First and/or second lowest densities are missing in isotherm, virial treatment will apply"
!		rho_IT(1)=rho_IT_calc(1)
!		rho_IT(2)=rho_IT_calc(2)
!		Z_IT(1)=1.0/(1.0-B2atHighestT*rho_IT(1))
!		Z_IT(2)=1.0+rho_IT(2)*(Zmin1OverRho_IT(3)+(Z_IT(1)-1.0)/rho_IT(1))/2.0
!		Zmin1OverRho_IT(1)=(Z_IT(1)-1.0)/rho_IT(1)
!		Zmin1OverRho_IT(2)=(Z_IT(2)-1.0)/rho_IT(2)
!		T_IT(1)=HighestT
!		T_IT(2)=HighestT
!		VirialTreatmentApplied="Yes"
!	endif

	Zmin1OverRho_IT(0)=B2atHighestT

	aDep_IT(0)= 0.0
	aDep_IT(2)= (rho_IT(2)-rho_IT(0))/6.0*(Zmin1OverRho_IT(0)+4.0*Zmin1OverRho_IT(1)+Zmin1OverRho_IT(2))
	aDep_IT(3)= 3.0/8.0*(rho_IT(3))/3.0*(Zmin1OverRho_IT(0)+3.0*Zmin1OverRho_IT(1)+3.0*Zmin1OverRho_IT(2)+Zmin1OverRho_IT(3))
	aDep_IT(1)= -1.0*(rho_IT(3)-rho_IT(1))/6.0*(Zmin1OverRho_IT(1)+4.0*Zmin1OverRho_IT(2)+Zmin1OverRho_IT(3))+aDep_IT(3)
	if(nItPts .eq. 9) then
		aDep_IT(4)= (rho_IT(4)-rho_IT(2))/6.0*(Zmin1OverRho_IT(2)+4.0*Zmin1OverRho_IT(3)+Zmin1OverRho_IT(4))+aDep_IT(2)
		aDep_IT(5)= 3.0/8.0*(rho_IT(5)-rho_IT(2))/3.0*(Zmin1OverRho_IT(2)+3.0*Zmin1OverRho_IT(3)+3.0*Zmin1OverRho_IT(4)+&
				Zmin1OverRho_IT(5))+aDep_IT(2)
		aDep_IT(7)= (rho_IT(7)-rho_IT(4))/6.0*(Zmin1OverRho_IT(4)+4.0*Zmin1OverRho_IT(5)+Zmin1OverRho_IT(7))+aDep_IT(4)
		aDep_IT(8)= 3.0/8.0*(rho_IT(8)-rho_IT(5))/3.0*(Zmin1OverRho_IT(5)+3.0*Zmin1OverRho_IT(6)+3.0*Zmin1OverRho_IT(7)+&
				Zmin1OverRho_IT(8))+aDep_IT(5)
		aDep_IT(6)= -1.0*(rho_IT(8)-rho_IT(6))/6.0*(Zmin1OverRho_IT(6)+4.0*Zmin1OverRho_IT(7)+Zmin1OverRho_IT(8))+aDep_IT(8)
		aDep_IT(9)= (rho_IT(9)-rho_IT(7))/6.0*(Zmin1OverRho_IT(7)+4.0*Zmin1OverRho_IT(8)+Zmin1OverRho_IT(9))+aDep_IT(7)
	elseif(nItPts .eq. 11) then
		aDep_IT(5)= (rho_IT(5)-rho_IT(2))/6.0*(Zmin1OverRho_IT(2)+4.0*Zmin1OverRho_IT(3)+Zmin1OverRho_IT(5))+aDep_IT(2)
		aDep_IT(7)= 3.0/8.0*(rho_IT(7)-rho_IT(2))/3.0*(Zmin1OverRho_IT(2)+3.0*Zmin1OverRho_IT(3)+3.0*Zmin1OverRho_IT(5)+&
				Zmin1OverRho_IT(7))+aDep_IT(2)
		aDep_IT(9)= (rho_IT(9)-rho_IT(5))/6.0*(Zmin1OverRho_IT(5)+4.0*Zmin1OverRho_IT(7)+Zmin1OverRho_IT(9))+aDep_IT(5)
		aDep_IT(10)= 3.0/8.0*(rho_IT(10)-rho_IT(7))/3.0*(Zmin1OverRho_IT(7)+3.0*Zmin1OverRho_IT(8)+3.0*Zmin1OverRho_IT(9)+&
				Zmin1OverRho_IT(10))+aDep_IT(7)
		aDep_IT(8)= -1.0*(rho_IT(10)-rho_IT(8))/6.0*(Zmin1OverRho_IT(8)+4.0*Zmin1OverRho_IT(9)+Zmin1OverRho_IT(10))+aDep_IT(10)
		aDep_IT(11)= (rho_IT(11)-rho_IT(9))/6.0*(Zmin1OverRho_IT(9)+4.0*Zmin1OverRho_IT(10)+Zmin1OverRho_IT(11))+aDep_IT(9)
		aDep_IT(6)= -1.0*(rho_IT(8)-rho_IT(6))/6.0*(Zmin1OverRho_IT(6)+4.0*Zmin1OverRho_IT(7)+Zmin1OverRho_IT(8))+aDep_IT(8)
		aDep_IT(4)= -1.0*(rho_IT(6)-rho_IT(4))/6.0*(Zmin1OverRho_IT(4)+4.0*Zmin1OverRho_IT(5)+Zmin1OverRho_IT(6))+aDep_IT(6)
	endif

	if(is3rdOrderPolZ .eqv. .true.) then
		!(z-1)/rho vs rho polynomial from rich's Gromacs results
!		afac = 82.47439886
!		bfac = -56.37106044
!		cfac = 16.51999812
!		dfac = -4.442779206


		!(z-1)/rho vs rho polynomial from NIST C12

		afac = 138.6509574
		bfac = -110.3823253
		cfac = 33.95336758
		dfac = -6.448337999

	!	y = a*x**3+b*x**2+c*x+d
	!	Yint = a/4.0*x**4+b/3.0*x**3+c/2.0*x**2+d*x

		x = rho_IT(1)
		Yint = afac/4.0*x**4+bfac/3.0*x**3+cfac/2.0*x**2+dfac*x
		aDep_IT(1) = Yint

		x = rho_IT(2)
		Yint = afac/4.0*x**4+bfac/3.0*x**3+cfac/2.0*x**2+dfac*x
		aDep_IT(2) = Yint

		x = rho_IT(3)
		Yint = afac/4.0*x**4+bfac/3.0*x**3+cfac/2.0*x**2+dfac*x
		aDep_IT(3) = Yint

		x = rho_IT(4)
		Yint = afac/4.0*x**4+bfac/3.0*x**3+cfac/2.0*x**2+dfac*x
		aDep_IT(4) = Yint

		x = rho_IT(5)
		Yint = afac/4.0*x**4+bfac/3.0*x**3+cfac/2.0*x**2+dfac*x
		aDep_IT(5) = Yint

		x = rho_IT(6)
		Yint = afac/4.0*x**4+bfac/3.0*x**3+cfac/2.0*x**2+dfac*x
		aDep_IT(6) = Yint

		x = rho_IT(7)
		Yint = afac/4.0*x**4+bfac/3.0*x**3+cfac/2.0*x**2+dfac*x
		aDep_IT(7) = Yint

		x = rho_IT(8)
		Yint = afac/4.0*x**4+bfac/3.0*x**3+cfac/2.0*x**2+dfac*x
		aDep_IT(8) = Yint

		x = rho_IT(9)
		Yint = afac/4.0*x**4+bfac/3.0*x**3+cfac/2.0*x**2+dfac*x
		aDep_IT(9) = Yint
	endif

	do j=iFirstIcPt,nItPts
			!if(isLinearuDepT .eqv. .true.) then
			!	aDep_IC(j,1)= ( ThousandOverT_IC(j,1)-ThousandOverT_IC(j,3) )/1000.d0* &
			!			( uDepT_IC(j,3)+ uDepT_IC(j,1) )/2.0d0+aDep_IT(j)
			!elseif(isLU .eqv. .true.) then

!				X1 = T_IC(j,1)
!				X2 = T_IC(j,2)
!				X3 = T_IC(j,3)
!				X4 = T_IC(j,3)
!				Y1 = uDepT_IC(j,1)
!				Y2 = uDepT_IC(j,2)
!				Y3 = uDepT_IC(j,3)
!				Y4 = uDepT_IC(j,3)
!				call getInterceptSlope(X1,X2,X3,X4,Y1,Y2,Y3,Y4,YINTERCEPT,SLOPE)
!				aDep_IC(j,1) = aDep_IT(j) + ( SLOPE * log(X3) - YINTERCEPT / X3) - ( SLOPE * log(X1) - YINTERCEPT / X1 )

			!	X1 = 1.0d0/T_IC(j,1)
			!	X2 = 1.0d0/T_IC(j,2)
			!	X3 = 1.0d0/T_IC(j,3)
			!	X4 = 1.0d0/T_IC(j,3)
			!	Y1 = uDepT_IC(j,1)/T_IC(j,1)
			!	Y2 = uDepT_IC(j,2)/T_IC(j,2)
			!	Y3 = uDepT_IC(j,3)/T_IC(j,3)
			!	Y4 = uDepT_IC(j,3)/T_IC(j,3)

			!	call getInterceptSlope(X1,X2,X3,X4,Y1,Y2,Y3,Y4,YINTERCEPT,SLOPE)
			!	aDep_IC(j,1) = aDep_IT(j) + ( SLOPE * X1 + YINTERCEPT * log(X1)) - ( SLOPE * X3 + YINTERCEPT * log(X3))

			!elseif(isQU .eqv. .true.) then
				aDep_IC(j,1)= ( ThousandOverT_IC(j,1)-ThousandOverT_IC(j,3) )/6.d0* &
						( uDepT_IC(j,3)+4.d0*uDepT_IC(j,2)+ uDepT_IC(j,1) )/1000.d0+aDep_IT(j)
				if(nPointsOnIC==4) then
				aDep_IC(j,1)= ( ThousandOverT_IC(j,1)-ThousandOverT_IC(j,4) )/8.d0* &
						( uDepT_IC(j,4)+3.d0*uDepT_IC(j,3)+3.d0*uDepT_IC(j,2)+ uDepT_IC(j,1) )/1000.d0+aDep_IT(j)
				endif
			!endif

	enddo


!<===============================This section is for automating aDep calculation but it's incomplete=============================
adep_IT2=0.0
rho_IT(0)=0.0
!write(*,'(14A7)') "i","b3_0","b2_5","b2_0","b1_5","b1_0","b0_5","here","f0_5","f1_0","f1_5","f2_0","f2_5","f3_0"
isVisited=0 !.false.
isVisited(0)= 1 !.true.
!aDep_IT2(7)=-0.755
!isVisited(7)=.true.
do j=1,100
do i=1,9
	here=isMember(rho_IT,rho_IT(i)-rho_increment*0.0)
	b0_5=isMember(rho_IT,rho_IT(i)-rho_increment*0.5)
	b1_0=isMember(rho_IT,rho_IT(i)-rho_increment*1.0)
	b1_5=isMember(rho_IT,rho_IT(i)-rho_increment*1.5)
	b2_0=isMember(rho_IT,rho_IT(i)-rho_increment*2.0)
	b2_5=isMember(rho_IT,rho_IT(i)-rho_increment*2.5)
	b3_0=isMember(rho_IT,rho_IT(i)-rho_increment*3.0)
	f0_5=isMember(rho_IT,rho_IT(i)+rho_increment*0.5)
	f1_0=isMember(rho_IT,rho_IT(i)+rho_increment*1.0)
	f1_5=isMember(rho_IT,rho_IT(i)+rho_increment*1.5)
	f2_0=isMember(rho_IT,rho_IT(i)+rho_increment*2.0)
	f2_5=isMember(rho_IT,rho_IT(i)+rho_increment*2.5)
	f3_0=isMember(rho_IT,rho_IT(i)+rho_increment*3.0)

	if(isVisited(i) .eq. 0) then
		if(b1_0 .AND. b0_5 .AND. isVisited(i-2).ne. 0) then
			aDep_IT2(i)= (rho_IT(i)-rho_IT(i-2))/6.0*(Zmin1OverRho_IT(i-2)+4.0*Zmin1OverRho_IT(i-1)+Zmin1OverRho_IT(i))+aDep_IT2(i-2)
			IntegrationMethod(i)="1/6-b"
			isVisited(i)=j
			exit
		endif
		if(b3_0 .AND. b2_0 .AND. b1_0 .AND. isVisited(i-3) .ne. 0) then
			aDep_IT2(i)= 3.0/8.0*(rho_IT(i)-rho_IT(i-3))/3.0*(Zmin1OverRho_IT(i-3)+3.0*Zmin1OverRho_IT(i-2)+3.0*Zmin1OverRho_IT(i-1)+&
			Zmin1OverRho_IT(i))+aDep_IT2(i-3)

			IntegrationMethod(i)="3/8-a"
			isVisited(i)=j
			exit
		endif
		if(b1_5 .AND. b1_0 .AND. b0_5 .AND. isVisited(i-3).ne. 0) then
			aDep_IT2(i)= 3.0/8.0*(rho_IT(i)-rho_IT(i-3))/3.0*(Zmin1OverRho_IT(i-3)+3.0*Zmin1OverRho_IT(i-2)+3.0*Zmin1OverRho_IT(i-1)+&
			Zmin1OverRho_IT(i))+aDep_IT2(i-3)
			IntegrationMethod(i)="3/8-b"
			isVisited(i)=j
			exit
		endif
		if(b2_0 .AND. b1_0 .AND. isVisited(i-2).ne. 0) then
			aDep_IT2(i)= (rho_IT(i)-rho_IT(i-2))/6.0*(Zmin1OverRho_IT(i-2)+4.0*Zmin1OverRho_IT(i-1)+Zmin1OverRho_IT(i))+aDep_IT2(i-2)
			IntegrationMethod(i)="1/6-a"
			isVisited(i)=j
			exit
		endif
		if(f2_0 .AND. f1_0 .AND. isVisited(i+2).ne. 0) then
			aDep_IT2(i)= -1.0*(rho_IT(i+2)-rho_IT(i))/6.0*(Zmin1OverRho_IT(i)+4.0*Zmin1OverRho_IT(i+1)+Zmin1OverRho_IT(i+2))+aDep_IT2(i+2)
			IntegrationMethod(i)="+2-1/6a"
			isVisited(i)=j
			exit
		endif
		if(f1_0 .AND. f0_5 .AND. isVisited(i+2).ne. 0) then
			aDep_IT2(i)= -1.0*(rho_IT(i+2)-rho_IT(i))/6.0*(Zmin1OverRho_IT(i)+4.0*Zmin1OverRho_IT(i+1)+Zmin1OverRho_IT(i+2))+aDep_IT2(i+2)
			IntegrationMethod(i)="+2-1/6b"
			isVisited(i)=j
			exit
		endif
	endif
	!write(*,'(I7,13L7)') i,b3_0,b2_5,b2_0,b1_5,b1_0,b0_5,here,f0_5,f1_0,f1_5,f2_0,f2_5,f3_0
enddo
enddo
	



	!write(*,*) "i	aDep_IT	  aDep_IT2   dev%   Method  isVisited?"
	!do i=1,9
	!	write(*,'(I2,3F10.3,A10,I2)') 	i,aDep_IT(i),aDep_IT2(i),abs((aDep_IT2(i)-aDep_IT(i))/aDep_IT(i)*100),&
	!					IntegrationMethod(i),isVisited(i)
	!enddo


!===================================================================================================================>
	
	write(*,*)
	write(*,*)'===============================Psat Calculation====================================='
	write(*,*)

	if(isB2Applied) then 
		B2factor = 1.0
	else
		B2factor = 0.0
	endif
	if(isB3Applied) then 
		B3factor = 1.0
	else
		B3factor = 0.0
	endif
	if(isB4Applied) then 
		B4factor = 1.0
	else
		B4factor = 0.0
	endif
	if(isB5Applied) then 
		B5factor = 1.0
	else
		B5factor = 0.0
	endif
	if(isB6Applied) then 
		B6factor = 1.0
	else
		B6factor = 0.0
	endif
	!T=0.0
	iExpoErr=0
	maxIter=500
	convergeStatus=-2
	do i=iFirstIcPt,nItPts

		tempPsat=Psat(i) !tempPsat is used for Converge/Diverge check
		tempRhov=rhoV(i) !tempRhoV is used for Converge/Diverge check

		!====Write Convergence Plot===
		write(rhoText,'(F7.5)')rho_IC(i)
		dumString1='.path'
		dumString2=trim(rhoText)//trim(dumString1)
		open(7845,file=dumString2)
		!====Write GvsRho Plot===
		dumString3='.rhov'
		dumString2=trim(rhoText)//trim(dumString3)
		open(53,file=dumString2)
		if(isConvergencePathNeeded)then
			open(5553,file=trim(rhoText))
			write(5553,*) T_IC(i,1), "0.0", rho_IC(i), "0.0"
		endif

		!=============================

		WRITE(*,*)
		Write(*,'(A,I2,A,F8.4,A)') "Iterations for Isochore",i,":",rho_IC(i)," (g/ml)"
		write(*,'(2A3,50A12)')"j","i","Tsat","Psat","rhoV","B2sat",&
				"aDepSat","uDep","zLiq","zVap","Hvap","drhoV","d2rhoV"	
		do j=1,maxIter
			!loopcounter = loopcounter + 1
			if(j==1)then
				zLiq(i)=0.001
			else
				zLiq(i)=Psat(i)/( rho_IC(i)/MW*8.3144598d0*Tsat(i) )
			endif
			!254 continue

			if(isMixedLQ)then
			if(i==iFirstIcPt)then
				isLT= .true.
				isQT= .false.
			else
				isLT= .false.
				isQT= .true.
			endif
			if(i==iFirstIcPt)then
				isQU= .true.
				isLinearuDepT= .false.
			else
				isQU= .false.
				isLinearuDepT= .true.
			endif
			endif

			if(isMixedLQ2)then
			if(i.ge.iFirstIcPt+2)then
				isQT= .true.
				isLT= .false.
			else
				isQT= .false.
				isLT= .true.
			endif
			if(i.ge.iFirstIcPt+2)then
				isQU= .true.
				isLU= .false.
			else
				isQU= .false.
				isLU= .true.
			endif
			endif

			if(isQT)then 
				Tsat(i)=TsatFinder(zLiq(i),1000.0/T_IC(i,3),Z_IC(i,3),1000.0/T_IC(i,2),Z_IC(i,2) &
					,1000.0/T_IC(i,1),Z_IC(i,1))
			elseif(isLT)then 
				X1 = 1000.0d0/T_IC(i,1)
				X2 = 1000.0d0/T_IC(i,2)
				X3 = 1000.0d0/T_IC(i,3)
				X4 = 1000.0d0/T_IC(i,3)
				Y1 = Z_IC(i,1)
				Y2 = Z_IC(i,2)
				Y3 = Z_IC(i,3)
				Y4 = Z_IC(i,3)
				call getInterceptSlope(X1,X2,X3,X4,Y1,Y2,Y3,Y4,YINTERCEPT,SLOPE)
				Tsat(i) = 1000.d0/ ((zLiq(i) - YINTERCEPT)/SLOPE)
			endif

!			if(isLinearuDepT .eqv. .true.) then
!				X1 = ThousandOverT_IC(i,1)
!				X2 = ThousandOverT_IC(i,1)
!				X3 = ThousandOverT_IC(i,3)
!				X4 = ThousandOverT_IC(i,3)
!				Y1 = uDepT_IC(i,1)
!				Y2 = uDepT_IC(i,1)
!				Y3 = uDepT_IC(i,3)
!				Y4 = uDepT_IC(i,3)
!				call getInterceptSlope(X1,X2,X3,X4,Y1,Y2,Y3,Y4,YINTERCEPT,SLOPE)
!				uDepTsat(i)= 1000.d0/Tsat(i) * SLOPE + YINTERCEPT
!				aDepSat(i)= ( 1000.d0/Tsat(i)-ThousandOverT_IC(i,1) )*( uDepTsat(i)+uDepT_IC(i,1) )/2000.d0 + aDep_IC(i,1)
			if(isLU .eqv. .true.) then

				X1 = T_IC(i,1)
				X2 = T_IC(i,2)
				X3 = T_IC(i,3)
				X4 = T_IC(i,3)
				Y1 = uDepT_IC(i,1)
				Y2 = uDepT_IC(i,2)
				Y3 = uDepT_IC(i,3)
				Y4 = uDepT_IC(i,3)
 				call getInterceptSlope(X1,X2,X3,X4,Y1,Y2,Y3,Y4,YINTERCEPT,SLOPE)
				uDepTsat(i) = (SLOPE * Tsat(i) + YINTERCEPT)

!				X1 = 1.0d0/T_IC(i,1)
!				X2 = 1.0d0/T_IC(i,2)
!				X3 = 1.0d0/T_IC(i,3)
!				X4 = 1.0d0/T_IC(i,3)
!				Y1 = uDepT_IC(i,1)/T_IC(i,1)
!				Y2 = uDepT_IC(i,2)/T_IC(i,2)
!				Y3 = uDepT_IC(i,3)/T_IC(i,3)
!				Y4 = uDepT_IC(i,3)/T_IC(i,3)
!				call getInterceptSlope(X1,X2,X3,X4,Y1,Y2,Y3,Y4,YINTERCEPT,SLOPE)
!				uDepTsat(i) = (SLOPE / Tsat(i) + YINTERCEPT)*Tsat(i)

			elseif(isQU .eqv. .true.) then
!				uDepTsat(i)=QuadExtrapolate(T_IC(i,1),uDepT_IC(i,1),T_IC(i,2),uDepT_IC(i,2),&
!					T_IC(i,3),uDepT_IC(i,3),Tsat(i))

				uDepTsat(i)=QuadExtrapolate(ThousandOverT_IC(i,1),uDepT_IC(i,1),ThousandOverT_IC(i,2),uDepT_IC(i,2),&
					ThousandOverT_IC(i,3),uDepT_IC(i,3),1000.d0/Tsat(i))	
			endif
			if(j==1)then
				aDepSat(i)= ( 1000.d0/Tsat(i)-ThousandOverT_IC(i,1) )*( uDepTsat(i)+uDepT_IC(i,1) )/2000.d0 + aDep_IC(i,1)
			else
				aDepSat(i)= ( 1000.d0/Tsat(i)-1000.d0/TsatOld )*( uDepTsat(i)+uDepSatOld )/2000.d0 + aDepSat(i)
			endif
			uDepSatOld = uDepTsat(i)
			TsatOld = Tsat(i)
			

			if(isThereB2correlationFromLiterature) then
				if(trim(CASN).eq."74-84-0") then
					Tr_rec=TC/Tsat(i)	
					open(2548,file="/home/mostafa/myProjects/SchultzVirialValues/"//trim(CASN)//".Bx")
					read(2548,*)
					read(2548,*)B2A,B2B,B2C,B2D,B2E,B2F
					read(2548,*)B3A,B3B,B3C,B3D,B3E,B3F
					read(2548,*)B4A,B4B,B4C,B4D,B4E,B4F
					read(2548,*)B5A,B5B,B5C,B5D,B5E,B5F
					read(2548,*)B6A,B6B,B6C,B6D,B6E,B6F
					close(2548)
					B2sat(i)=B2A*Tr_rec**5+B2B*Tr_rec**4+B2C*Tr_rec**3+B2D*Tr_rec**2+B2E*Tr_rec**1+B2F*Tr_rec**0
					B3sat(i)=B3A*Tr_rec**5+B3B*Tr_rec**4+B3C*Tr_rec**3+B3D*Tr_rec**2+B3E*Tr_rec**1+B3F*Tr_rec**0	
					B4sat(i)=B4A*Tr_rec**5+B4B*Tr_rec**4+B4C*Tr_rec**3+B4D*Tr_rec**2+B4E*Tr_rec**1+B4F*Tr_rec**0
					B5sat(i)=B5A*Tr_rec**5+B5B*Tr_rec**4+B5C*Tr_rec**3+B5D*Tr_rec**2+B5E*Tr_rec**1+B5F*Tr_rec**0
					B6sat(i)=B6A*Tr_rec**5+B6B*Tr_rec**4+B6C*Tr_rec**3+B6D*Tr_rec**2+B6E*Tr_rec**1+B6F*Tr_rec**0
				elseif(trim(CASN).eq."111-65-9") then
			!		!===========Kofke correlation for TraPPE-C8 only================
					!TC = 568.7308641592
					Tr_rec=TC/Tsat(i)	

					!B2(cc/g)=-7.4672*(1/Tr)^3+17.7516 (1/Tr)^2-25.9879 (1/Tr)+10.659
					!T=300-600K
					B2A=-7.4672	
					B2B=17.7516 	
					B2C=-25.9879	
					B2D=10.659
					B2sat(i)=B2A*Tr_rec**3+B2B*Tr_rec**2+B2C*Tr_rec+B2D



					!B3(cc^2/g^2)=-678.8960*(1/Tr)^3+2356.0898*(1/Tr)^2-2729.2549*(1/Tr)+1064.2969
					!T=350-520K 
					B3A=-678.8960	
					B3B=2356.0898	
					B3C=-2729.2549	
					B3D=1064.2969
					B3sat(i)=B3A*Tr_rec**3+B3B*Tr_rec**2+B3C*Tr_rec+B3D	

					!Tr=
					!B4A=
					!B4B=
					!B4C=
					!B4D=
					!B4E=
					!B4sat(i)=B4A*Tr_rec**4+B4B*Tr_rec**3+B4C*Tr_rec**2+B4D*Tr_rec+B4E	

					!write(*,*)Tr_rec,B2sat(j),B3sat(j)
			!		!==============================================================
				elseif(trim(CASN).eq."112-40-3") then
					!===========Kofke correlation for TraPPE-C12 only================
					Tr_rec=TC/Tsat(i)	

					!Tr=0.53-1.06
					B2A=-18.0757137788	
					B2B=50.4498624402	
					B2C=-62.7312922978	
					B2D=24.8250498773
					B2sat(i)=B2A*Tr_rec**3+B2B*Tr_rec**2+B2C*Tr_rec+B2D

					!Tr=
					!B3A=	
					!B3B=	
					!B3C=	
					!B3D=
					!B3sat(i)=B3A*Tr_rec**3+B3B*Tr_rec**2+B3C*Tr_rec+B3D	

					!Tr=
					!B4A=	
					!B4B=	
					!B4C=	
					!B4D=	
					!B4E=
					!B4sat(i)=B4A*Tr_rec**4+B4B*Tr_rec**3+B4C*Tr_rec**2+B4D*Tr_rec+B4E	

					!write(*,*)Tr_rec,B2sat(i),B3sat(i)
					!==============================================================
				elseif(trim(CASN).eq."7732-18-5") then
					!===========Kofke correlation for TraPPE-C12 only================
					Tr_rec=TC/Tsat(i)	

					!T=290-610
					B2A=-223.8683788	
					B2B=881.8127394	
					B2C=-1190.822651	
					B2D=534.3079787
					B2sat(i)=B2A*Tr_rec**3+B2B*Tr_rec**2+B2C*Tr_rec+B2D

					!Tr=
					!B3A=	
					!B3B=	
					!B3C=	
					!B3D=
					!B3sat(i)=B3A*Tr_rec**3+B3B*Tr_rec**2+B3C*Tr_rec+B3D		

					!write(*,*)Tr_rec,B2sat(i),B3sat(i)
					!==============================================================
				endif
			endif
			if(doesVirialCalcITpointsExist .AND. doesVirialCalcIT2pointsExist) then
				B2sat(i) = Acoef + Bcoef/Tsat(i) + Ccoef / Tsat(i)**3
			endif

			if(isB2FromDippr) call Dippr(CASN,"SVR",Tsat(i),B2sat(i),"cm^3|gm")

			if((isNist .eqv. .true.) .and. (doesVirialCalcITpointsExist .eqv. .false.)) then
				if(disableExtrapolation) then
					zLiq(i)=Z_IC(i,1)
					Tsat(i)=T_IC(i,1)
					uDepTsat(i)=uDepT_IC(i,1)
					aDepSat(i)=aDep_IC(i,1)
				endif
				!B2sat(i)=Zstd_IC(i,1)
				!B3sat(i)=P_IC(i,1)
				!======These xB2 and xB3 coefficients are only for NIST C12=======
				AB2=1.7146731789
				BB2=-2499.9292130758
				CB2=-1447246630.01158
				DB2=-1.68E+21
				EB2=3.06E+23

				AB3=-15.7833039202
				BB3=21971.615762915
				CB3=3775034339.88898
				DB3=-2.33E+21
				EB3=4.31E+23
				T=Tsat(i)
				B2sat(i)=AB2+BB2/T+CB2/T**3+DB2/T**8+EB2/T**9
				B3sat(i)=AB3+BB3/T+CB3/T**3+DB3/T**8+EB3/T**9	
				!=================================================================
			endif
			B2sat(i)=B2sat(i)*B2factor
			B3sat(i)=B3sat(i)*B3factor
			B4sat(i)=B4sat(i)*B4factor
			B5sat(i)=B5sat(i)*B5factor
			B6sat(i)=B6sat(i)*B6factor
			expArgAZ1=aDepSat(i)+zLiq(i)-1.d0
			if(expArgAZ1 > 33)iExpoErr=1
			if(j==1)then
				expArgB2=-2.d0*B2sat(j)*rho_IC(j)*exp(expArgAZ1) 
				expArgB3=-1.5d0*B3sat(j)*(rho_IC(j)*exp(expArgAZ1))**2
				expArgB4=-4.d0/3.d0*B4sat(j)*(rho_IC(j)*exp(expArgAZ1))**3
				expArgB5=-5.d0/4.d0*B5sat(j)*(rho_IC(j)*exp(expArgAZ1))**4
				expArgB6=-6.d0/5.d0*B6sat(j)*(rho_IC(j)*exp(expArgAZ1))**5
			else
				expArgB2=-2.d0*B2sat(i)*rhoV(i)
				expArgB3=-1.5d0*B3sat(i)*rhoV(i)**2
				expArgB4=-4.d0/3.d0*B4sat(i)*rhoV(i)**3
				expArgB5=-5.d0/4.d0*B5sat(i)*rhoV(i)**4
				expArgB6=-6.d0/5.d0*B6sat(i)*rhoV(i)**5
			endif

			rhoV(i)= rho_IC(i)*exp(expArgAZ1)*exp(expArgB2)*exp(expArgB3)*exp(expArgB4)*exp(expArgB5)*exp(expArgB6)
			rhoVp(i)= rhoV(i)*(-2.d0*B2sat(i) - 3.d0*B3sat(i)*rhoV(i) - 4.d0*B4sat(i)*rhoV(i)**2 &
					- 5.d0*B5sat(i)*rhoV(i)**3 - 6.d0*B6sat(i)*rhoV(i)**4)
			rhoVpp(i)= rhoV(i)*( -3.d0*B3sat(i) - 8.d0*B4sat(i)*rhoV(i) - 15.d0*B5sat(i)*rhoV(i)**2 - 24.d0*B6sat(i)*rhoV(i)**3) + &
					rhoVp(i)*( -2.d0*B2sat(i) - 3.d0*B3sat(i)*rhoV(i) - 4.d0*B4sat(i)*rhoV(i)**2 &
					- 5.d0*B5sat(i)*rhoV(i)**3 - 6.d0*B6sat(i)*rhoV(i)**4)
			zVsat=  1.d0+B2sat(i)*rhoV(i)+B3sat(i)*rhoV(i)**2+B4sat(i)*rhoV(i)**3+B5sat(i)*rhoV(i)**4+B6sat(i)*rhoV(i)**5
			Psat(i)=( zVsat )*rhoV(i)/MW*8.3144598d0*Tsat(i)
			denom=( 1.0/Tsat(i) - 1.0/HighestT ) 
			dB2_dBeta(i)=(B2sat(i)-B2atHighestT)/denom
			hSatVap= dB2_dBeta(i)*rhoV(i)/Tsat(i)+zVsat-1	
			hSatLiq= uDepTSat(i)/Tsat(i)+zLiq(i)-1
			Hvap(i)= ( hSatVap - hSatLiq)*8.3144598d0*Tsat(i)/1000.0

			write(*,'(2I3,F12.5,F15.9,50F12.7)')j,i,Tsat(i),Psat(i),rhoV(i),B2sat(i),&
				aDepSat(i),uDepTsat(i)/Tsat(i),zLiq(i),zVsat,Hvap(i),rhoVp(i),rhoVpp(i) &
				,aDepSat(i) - aDep_IC(i,1)

			!<====Write Convergence Plot===
			write(7845,*) tempRhoV,tempRhoV
			write(7845,*) tempRhoV,rhoV(i)
			!=============================>

			!<====Write GvsRho Plot===
			do kk=1,1000
				rhoVV=0.001*kk
				GofRhov=rho_IC(i)*exp(expArgAZ1)*exp(-2.d0*B2sat(i)*rhoVV)*exp(-1.5d0*B3sat(i)*rhoVV**2)
				GpofRhoV=rho_IC(i)*exp(expArgAZ1)*exp(-2.d0*B2sat(i)*rhoVV)*exp(-1.5d0*B3sat(i)*rhoVV**2) &
					*( -2.d0*B2sat(i) -3.d0*B3sat(i)*rhoVV )
				write(53,*) rhoVV,rhoVV,GofRhov !,GpofRhoV
			enddo
			write(53,*)
			write(53,*)
			!=============================>

			!<====Convergence Check===
			PsatIncrement=abs((tempPsat-Psat(i))/Psat(i)*100.0)
			rhoVIncrement=abs((tempRhoV-rhoV(i))/rhoV(i)*100.0)
			if(PsatIncrement .le. 1e-3 .and. rhoVIncrement .le. 1e-3) then
				if(rhoVp(i) .lt. 1.d0 .AND. rhoVpp(i) .gt. 0.d0) then
					convergeStatus(i)=1
					Write(*,'(A,I2,A,F8.4,A)') "Isochore",i,":",rho_IC(i)," (g/ml):"
					write(*,'(A19,I3,A)') "Convergence Status= ",convergeStatus(i)," (Converged to first root)"				
					exit
				elseif(rhoVp(i) .gt. 1.d0 .AND. rhoVpp(i) .gt. 0.d0)then
					convergeStatus(i)=2
					Write(*,'(A,I2,A,F8.4,A)') "Isochore",i,":",rho_IC(i)," (g/ml):"
					write(*,'(A19,I3,A)') "Convergence Status= ",convergeStatus(i)," (Converged to second root)"				
					exit
				elseif(rhoVpp(i) .lt. 0.d0) then
					convergeStatus(i)=3
					Write(*,'(A,I2,A,F8.4,A)') "Isochore",i,":",rho_IC(i)," (g/ml):"
					write(*,'(A19,I3,A)') "Convergence Status= ",convergeStatus(i)," (Converged to third root)"				
					exit
				endif
			endif
			if(j .eq. maxIter)then
				!convergeStatus(i)=-1
				convergeStatus(i)=1
				Write(*,'(A,I2,A,F8.4,A)') "Isochore",i,":",rho_IC(i)," (g/ml):"
				write(*,'(A19,I3,A)') "Convergence Status= ",convergeStatus(i)," (Maximum Iteration s reached)"				
				
				!zLiq(i)=0.1
				!loopcounter = 1
				!goto 254
			endif

			tempPsat = Psat(i)
			tempRhoV = rhoV(i)

			if(Psat(i) .lt. 0.0d0 .OR. rhoV(i) .lt. 0.0d0 .OR. Psat(i) .gt. 10.0) then 
				convergeStatus(i)=0
				Write(*,'(A,I2,A,F8.4,A)') "Isochore",i,":",rho_IC(i)," (g/ml):"
				write(*,'(A19,I3,A)') "Convergence Status= ",convergeStatus(i)," (Diverged)"				
			endif

			!if(rhoV(i) .gt. 1.d0/VC) then 
				!write(*,*) "rhoV is bigger that critical density. Iteration will stop!"
				!exit
			!endif
			!=============================>
			if(isConvergencePathNeeded)then
				write(5553,*) Tsat(i), Psat(i), rho_IC(i), rhoV(i) 
			endif
		enddo


			close(53)
			close(7845)
			if(isConvergencePathNeeded)then
				close(5553)
			endif
	enddo



	PsatRmsd=0
	TsatRmsd=0
	pSatBias=0
	TsatBias=0
	rhoLRmsd=0
	rhoLBias=0

	nConvergedICs=0

	do i=iFirstIcPt,nItPts
		if(isMoleculeUnknown.eqv..false.) then
			call Dippr(CASN,"VP",Tsat(i),PsatDip(i),"Mpa")
			call Dippr(CASN,"LDN",Tsat(i),RhoLDip(i),"gm|cm^3")
			call Dippr(CASN,"HVP",Tsat(i),HvapDip(i),"kJ|mol")
		else
			PsatDip(i) = 0.0
			RhoLDip(i) = 0.0
			HvapDip(i) = 0.0
		endif
		if(isNist) then
			!PsatDip(i)=simTime_IC(i,1)
			!RhoLDip(i)=rho_IC(i)
			HvapDip(i)=eqTime_IC(i,1)
		endif
		PsatLnDev(i)=LOG(Psat(i)/PsatDip(i))*100.0
		!For DIPPR compounds Tsat should be calculated at the imposed rho. T_IC(i,1) is not always equal to DIPPR, because initial Tsat is not always known
		TsatLnDev(i)=LOG(Tsat(i)/T_IC(i,1))*100.0 
		RhoLLnDev(i)=LOG(rho_IC(i)/RhoLDip(i))*100.0
		HvapLnDev(i)=LOG(Hvap(i)/HvapDip(i))*100.0
		if(convergeStatus(i) .eq. 1) then	!If fixed-point method was convereged to first root
			PsatBIAS=PsatBIAS+PsatLnDev(i)
			TsatBIAS=TsatBIAS+TsatLnDev(i)
			RhoLBIAS=RhoLBIAS+RhoLLnDev(i)
			HvapBIAS=HvapBIAS+HvapLnDev(i)

			PsatRmsd=PsatRmsd+PsatLnDev(i)**2
			TsatRmsd=TsatRmsd+TsatLnDev(i)**2
			RhoLRmsd=RhoLRmsd+RhoLLnDev(i)**2
			HvapRmsd=HvapRmsd+HvapLnDev(i)**2
			nConvergedICs=nConvergedICs+1
		endif
	enddo
        write(*,*)
	PsatRmsd=SQRT(PsatRmsd/nConvergedICs)
	TsatRmsd=SQRT(TsatRmsd/nConvergedICs)
	RhoLRmsd=SQRT(RhoLRmsd/nConvergedICs)
	HvapRmsd=SQRT(HvapRmsd/nConvergedICs)

	PsatBIAS=PsatBIAS/nConvergedICs 
	TsatBIAS=TsatBIAS/nConvergedICs 
	RhoLBIAS=RhoLBIAS/nConvergedICs 
	HvapBIAS=HvapBIAS/nConvergedICs

	write(*,*)
	write(*,*)'===============================Compound and Simulation Info====================================='
	write(*,*)
	do i=1,nSiteTypes
		SigOfSite(i)="s("//trim(SiteTypeNames(i))//")"
		EpsOfSite(i)="e("//trim(SiteTypeNames(i))//")"
		AOfSite(i)="A("//trim(SiteTypeNames(i))//")"
	enddo

	status=getcwd( Address ) 
   	Address = TRIM(Address)
	index = SCAN(Address,"/",.true.)
	Directory = Address(1:index-1)
	FolderName = Address(index+1:)
	index = SCAN(FolderName,"-")
	myName = FolderName(index+1:)
	index = SCAN(myName,"-")
	myName = myName(:index-1)

	write(*,'(A,A)')"Folder Name: ",trim(FolderName)
	write(*,*)
	!write(*,'(A12,A50)')"Address:",trim(Address)
	!write(*,'(A)')trim(d(1))
	write(*,'(A9,1x,A)')"CASN:",trim(CASN)
	write(*,'(A9,1x,A)')"CNAM:",trim(CNAM)
	write(*,'(A9,1x,A)')"FAM:",trim(FAM)
	write(*,'(A9,1x,A)')"FORM:",trim(FORM)
	write(*,'(A9,1x,A)')"INAM:",trim(INAM)
	write(*,'(A9,1x,A)')"NAME:",trim(COMP_NAME)
	write(*,'(A9,1x,A)')"SMIL:",trim(SMIL)
	write(*,'(A9,1x,A)')"STRU:",trim(STRU)
	write(*,*)
	write(*,'(A9,1x,F8.4,1x,A7)') "MW:",MW !,"(g/mol)"
	write(*,'(A9,1x,F8.2,1x,A7)') "TC:",TC !,"(K)"
	write(*,'(A9,1x,F8.4,1x,A7)') "PC:",PC !,"(Mpa)"
	write(*,'(A9,1x,F8.4,1x,A7)') "RHOC:",1.d0/VC !,"(g/ml)"
	write(*,*)
	write(*,'(A9,1x,15(F8.2))')"T_IT:",HighestT
	write(*,'(A9,1x,15(I8))')"N_IT:",nItPts
	write(*,'(A9,1x,15(F8.4))')"RHO_IT:",(rho_IT(j),j=1,nItPts)
	write(*,'(A9,1x,15(I8))')"NMOL:",(N_IT(j),j=1,nItPts)
	write(*,*)
	write(*,'(A9,1x,15(F8.4))')"RHO_HIGH:",highestRho
	write(*,'(A9,1x,15(I8))')"N_IC:",nICs
	write(*,'(A9,1x,15(F8.4))')"RHO_IC:",(rho_IC(j),j=iFirstIcPt,nItPts)
	icount=0
	do i=iFirstIcPt,nItPts
		icount=icount+1
		write(*,'(A7,I1,A,1x,15F8.2)') "T_IC",icount,":",T_IC(i,1),T_IC(i,2)
	enddo
	write(*,*)	
	!write(*,'(A9,1x,A8)')"Virial?",VirialTreatmentApplied


	write(*,*)
	write(*,*)'===============================IC Info====================================='
	write(*,*)

	write(*,'(11(A12,1x))')"(K)","(g/ml)","","",""
	write(*,'(11(A12,1x))')"T","rho","Z","aDep","uDep"
	do i=iFirstIcPt,nItPts
		do k=1,3
!			if(k==1)then
!				T=Tsat(i)
!			else
!				T=T_IC(i,k)
!			endif
			write(*,'(F12.2,1x,10(F12.6,1x))') T_IC(i,k),rho_IC(i),Z_IC(i,k),&
					aDep_IC(i,k),uDepT_IC(i,k)/T_IC(i,k)
		enddo
	!write(*,*)
	!write(*,*)
	enddo
	write(*,*)
	write(*,*)'===============================IT Info====================================='
	write(*,*)
	write(*,'(11(A12,1x))')"(K)","(g/ml)","","",""
	write(*,'(11(A12,1x))')"T","rho","Z","aDep","uDep","rho"
	if(doesVirialCalcIT2pointsExist) then
		do i=1,4
			write(*,'(F12.2,1x,10(F12.6,1x))') T_IT2_vr(i),rho_IT2_vr(i),Z_IT2_vr(i),&
						zero,zero,zero
		enddo
		write(*,*)
	endif

	if(doesVirialCalcITpointsExist) then
		do i=1,3
			write(*,'(F12.2,1x,10(F12.6,1x))') T_IT_vr(i),rho_IT_vr(i),Z_IT_vr(i),&
						zero,zero,zero
		enddo
	endif

	do i=1,nItPts
		write(*,'(F12.2,1x,10(F12.6,1x))') T_IT(i),rho_IT(i),Z_IT(i),&
					aDep_IT(i),uDepT_IT(i)/T_IT(i),rho_IT(i)
	enddo

	write(*,*)
	write(*,*)'===============================Saturation Info====================================='
	write(*,*)

	write(*,'(A5,A7,A10,A7,A18,A9,A10,A7,A12,A10,A7,A10,A10,A10,A10,A10,A10)')&
			"","","(K)","","(MPa)","","(g/ml)","","(g/ml)","(KJ/mol)","",&
			  "(MPa)","(g/ml)","(KJ/mol)","(ml/g)","",""
	write(*,'(A5,A7,A10,A7,A18,A9,A10,A7,A12,A10,A7,A10,A10,A10,A10,A10,A10)')&
			"Conv","Tr","Tsat","Dev%","Psat","Dev%","rhoL","Dev%","rhoV","Hvap","Dev%",&
			"PsatDip","rhoLDip","HvapDip","B2sat","aDepSat","uDepSat"
	do i=iFirstIcPt,nItPts
		!if(convergeStatus(i)==1)&
		write(*,'(I5,F7.3,F10.2,F7.2,F18.12,F9.2,F10.4,F7.2,F12.8,F10.4,F7.2,F10.6,F10.4,F10.4,F10.4,F10.4,F10.4)') &
		convergeStatus(i),Tsat(i)/TC,Tsat(i),TsatLnDev(i),Psat(i),PsatLnDev(i),rho_IC(i),RhoLLnDev(i),rhoV(i),Hvap(i),HvapLnDev(i),&
		PsatDip(i),RhoLDip(i), HvapDip(i),B2sat(i),aDepSat(i),uDepTSat(i)/Tsat(i)
	enddo

	if (isCriticalNeeded)then
		write(*,*)
		write(*,*)'===============================Critical Properties====================================='
		write(*,*)

		nDiverged = 0
		do i=iFirstIcPt,nItPts
			if(convergeStatus(i)/=1) nDiverged = nDiverged + 1
		enddo
		!write(*,*)nDiverged
		do i=1,4	!SMR: 4pts
			TsatSL(i) = Tsat(i-iFirstIcPt+nItPts-nDiverged)
			rhoLSL(i) = rho_IC(i-iFirstIcPt+nItPts-nDiverged)
			rhoVSL(i) = rhoV(i-iFirstIcPt+nItPts-nDiverged)
			PsatSL(i) = Psat(i-iFirstIcPt+nItPts-nDiverged)
		enddo


	!	do i=1,5
	!		write(*,*)TsatSL(i),rhoLSL(i),rhoVSL(i),PsatSL(i)
	!	enddo
		call ScalingLaw(CritT,CritRho)
		CritTemp = CritT

		Y1 = log(PsatSL(1))
		Y2 = log(PsatSL(2))
		Y3 = log(PsatSL(3))
		Y4 = log(PsatSL(4))

		X1 = 1000.0/TsatSL(1)
		X2 = 1000.0/TsatSL(2)
		X3 = 1000.0/TsatSL(3)
		X4 = 1000.0/TsatSL(4)
				
		call getInterceptSlope(X1,X2,X3,X4,Y1,Y2,Y3,Y4,YINTERCEPT,SLOPE)
		CritP = EXP(slope*1000.0/CritT+yintercept)
		write(*,'(A49)')"Dev%"
		write(*,'(A25,1x,F10.2,3x,F10.2)') "Critical Temperature[K]:",CritT,(CritT-TC)/TC*100
		write(*,'(A25,1x,F10.4,3x,F10.2)') "Critical Density[g/ml]:",CritRho,(CritRho-1.d0/VC)/(1.d0/VC)*100
		write(*,'(A25,1x,F10.4,3x,F10.2)') "Critical Pressure[MPa]:",CritP,(CritP-PC)/PC*100

		call CriticalPcalc(CritTemp,CritPress,Accentric)
		write(*,'(A25,1x,F10.4,3x,F10.2)') "Critical Pressure LK[MPa]:",CritPress,(CritPress-PC)/PC*100
		write(*,'(A25,1x,F10.4,3x,F10.2)') "Accentric Factor:",Accentric
	endif

	write(*,*)
	write(*,*)'===============================Final Results====================================='
	write(*,*)
!	if(isMoleculeUnknown.eqv..false.) then
!		write(*,'(3(A10,1x),A1,8(A7,1x),A1,12(A9,1x))') &
!			"POT","FAM","NAME","|","%PsatR","%PsatB","%TsatR" &
!			,"%TsatB","%RhoLR","%RhoLB","%HvapR","%HvapB" &
!			,"|",(trim(SigOfSite(j)),trim(EpsOfSite(j)),trim(AOfSite(j)),j=1,nSiteTypes)
!		write(*,'(3(A10,1x),A1,8(f7.2,1x),A1,6(f9.4,1x,f9.2,1x,f9.2,1x))') &
!			trim(potentialName),trim(FAM),trim(myName),"|",PsatRmsd &
!			,PsatBIAS,TsatRmsd,TsatBIAS,RhoLRmsd,RhoLBIAS,HvapRmsd,HvapBIAS, &
!			"|",(sigma(j),epsilon(j),AorN(j),j=1,nSiteTypes)
!	else
!		write(*,'(8(A7,1x),A1,12(A9,1x))') &
!			"%PsatR","%PsatB","%TsatR" &
!			,"%TsatB","%RhoLR","%RhoLB","%HvapR","%HvapB" &
!			,"|",(trim(SigOfSite(j)),trim(EpsOfSite(j)),trim(AOfSite(j)),j=1,nSiteTypes)
!		write(*,'(8(f7.2,1x),A1,6(f9.4,1x,f9.2,1x,f9.2,1x))') &
!			PsatRmsd,PsatBIAS,TsatRmsd,TsatBIAS,RhoLRmsd,RhoLBIAS,HvapRmsd,HvapBIAS, &
!			"|",(sigma(j),epsilon(j),AorN(j),j=1,nSiteTypes)
!	endif



contains

logical function isMember(array,target)
double precision, intent(in) :: array(:)
double precision, intent(in) :: target
integer :: n, i,count
count = 0
n = size(array)
isMember=.false.
do i = 0, n
	arrayValue=array(i)
	targetValue=target

	dev = sqrt((arrayValue-targetValue)**2)
	!if(arrayValue.lt. 1e-5 .AND. targetValue.lt. 1e-5) then
	!	dev = 0.0
	!	endif
	!write(*,*) i,arrayValue,targetValue,dev
	if(dev .lt. 1e-2 ) isMember=.true.
enddo

end function isMember


end program main
	

subroutine CriticalPcalc(CritTemp,CritPress,Accentric)
	implicit double precision (A-H,O-Z)
	parameter (nParameters = 2, nFunctions = 4) !SMR: changes done for using 4 points instead of 5 when critical calculations
	double precision :: parm(nParameters)
	double precision :: deviate(nFunctions)
	double precision :: CritTemp
	!external EvalDevForScalingLaw
	double precision TsatSL(9),rhoLSL(9),rhoVSL(9),PsatSL(9)
	common TsatSL,rhoLSL,rhoVSL,PsatSL
	common parm

	tol=1e-8
	factor=0.0001

	CritPress = 10.0
	Accentric = 0.5
	parm(1) = CritPress
   	parm(2) = Accentric
	nFunctionsalls = 100000
	

	call LmDifEz(EvalDevForCriticalP,nFunctions,nParameters,parm,factor,deviate,tol,iErrCode,stdErr,nFunctionsalls)

	CritPress = parm(1)
	Accentric = parm(2)
	
	contains


!*********************************************************
subroutine EvalDevForCriticalP(nFunctions,nParameters,parm,deviate,iFlag)
	implicit double precision (A-H,O-Z)
	double precision :: parm(nParameters)
	double precision :: deviate(nFunctions)
	double precision TsatSL(9),rhoLSL(9),rhoVSL(9),PsatSL(9)
	common TsatSL,rhoLSL,rhoVSL,PsatSL

	CritPress = parm(1)
	Accentric = parm(2)

	Tr1 = TsatSL(1)/CritTemp
	Tr2 = TsatSL(2)/CritTemp
	Tr3 = TsatSL(3)/CritTemp
	Tr4 = TsatSL(4)/CritTemp
	Tr5 = TsatSL(5)/CritTemp

	Pr1 = PsatSL(1)/CritPress
	Pr2 = PsatSL(2)/CritPress
	Pr3 = PsatSL(3)/CritPress
	Pr4 = PsatSL(4)/CritPress
	Pr5 = PsatSL(5)/CritPress

	f01 = 5.92714 - 6.09648/Tr1 - 1.28862 * log(Tr1) + 0.1169347 * Tr1**6
	f02 = 5.92714 - 6.09648/Tr2 - 1.28862 * log(Tr2) + 0.1169347 * Tr2**6
	f03 = 5.92714 - 6.09648/Tr3 - 1.28862 * log(Tr3) + 0.1169347 * Tr3**6
	f04 = 5.92714 - 6.09648/Tr4 - 1.28862 * log(Tr4) + 0.1169347 * Tr4**6
	f05 = 5.92714 - 6.09648/Tr5 - 1.28862 * log(Tr5) + 0.1169347 * Tr5**6

	f11 = 15.2518 - 15.6875/Tr1 - 13.4721 * log(Tr1) +   0.43577 * Tr1**6
	f12 = 15.2518 - 15.6875/Tr2 - 13.4721 * log(Tr2) +   0.43577 * Tr2**6
	f13 = 15.2518 - 15.6875/Tr3 - 13.4721 * log(Tr3) +   0.43577 * Tr3**6
	f14 = 15.2518 - 15.6875/Tr4 - 13.4721 * log(Tr4) +   0.43577 * Tr4**6
	f15 = 15.2518 - 15.6875/Tr5 - 13.4721 * log(Tr5) +   0.43577 * Tr5**6

	deviate(1) = sqrt( (	log(Pr1) - ( f01 + Accentric * f11 )	)**2 )
	deviate(2) = sqrt( (	log(Pr2) - ( f02 + Accentric * f12 )	)**2 )
	deviate(3) = sqrt( (	log(Pr3) - ( f03 + Accentric * f13 )	)**2 )
	deviate(4) = sqrt( (	log(Pr4) - ( f04 + Accentric * f14 )	)**2 )
	!deviate(5) = sqrt( (	log(Pr5) - ( f05 + Accentric * f15 )	)**2 ) SMR: 4pts

	!write(*,'(14(F15.7,1x))') parm(1),parm(2),deviate(1),deviate(2),deviate(3),deviate(4),deviate(5)

return
end subroutine EvalDevForCriticalP
	

end subroutine CriticalPcalc

subroutine ScalingLaw(CritT,CritRho)
	implicit double precision (A-H,O-Z)
	parameter (nParameters = 4, nFunctions = 8) !SMR: changes done for using 4 points instead of 5 when critical calculation
	double precision :: parm(nParameters)
	double precision :: deviate(nFunctions)
	!external EvalDevForScalingLaw
	double precision TsatSL(9),rhoLSL(9),rhoVSL(9),PsatSL(9)
	common TsatSL,rhoLSL,rhoVSL,PsatSL
	common parm
	common CritTemp
	A = 1.0
	B = 1.0
	CritT = 1000.0
	CritRho = 1.0


	tol=1e-7
	factor=0.0001d0

	parm(1) = A
   	parm(2) = B
   	parm(3) = CritT
   	parm(4) = CritRho
	nFunctionsalls = 100000


	call LmDifEz(EvalDevForScalingLaw,nFunctions,nParameters,parm,factor,deviate,tol,iErrCode,stdErr,nFunctionsalls)

	A = parm(1)
	B = parm(2)
	CritT = parm(3)
	CritRho = parm(4)

	!write(*,*) A,B,CritT,CritRho
	!write(*,*)"iErrCode=",iErrCode
	!write(*,*)"stdErr",stdErr

	
	contains


!*********************************************************
subroutine EvalDevForScalingLaw(nFunctions,nParameters,parm,deviate,iFlag)
	implicit double precision (A-H,O-Z)
	double precision :: parm(nParameters)
	double precision :: deviate(nFunctions)
	double precision TsatSL(9),rhoLSL(9),rhoVSL(9),PsatSL(9)
	common TsatSL,rhoLSL,rhoVSL,PsatSL

	A = parm(1)
	B = parm(2)
	CritT = parm(3)
	CritRho = parm(4)

	deviate(1) = sqrt( (rhoLSL(1)-rhoVSL(1) - B*(CritT-TsatSL(1))**0.325)**2 ) 
	deviate(2) = sqrt( (rhoLSL(2)-rhoVSL(2) - B*(CritT-TsatSL(2))**0.325)**2 )  
	deviate(3) = sqrt( (rhoLSL(3)-rhoVSL(3) - B*(CritT-TsatSL(3))**0.325)**2 ) 
	deviate(4) = sqrt( (rhoLSL(4)-rhoVSL(4) - B*(CritT-TsatSL(4))**0.325)**2 )  
	!deviate(5) = sqrt( (rhoLSL(5)-rhoVSL(5) - B*(CritT-TsatSL(5))**0.325)**2 )  !SMR: changes done for using 4 points instead of 5 when critical calculation

	deviate(5) = sqrt( ((rhoLSL(1)+rhoVSL(1))/2.0 - (CritRho+A*(CritT-TsatSL(1))))**2 )  !SMR: changes done for using 4 points instead of 5 when critical calculation
	deviate(6) = sqrt( ((rhoLSL(2)+rhoVSL(2))/2.0 - (CritRho+A*(CritT-TsatSL(2))))**2 )  !SMR: changes done for using 4 points instead of 5 when critical calculation
	deviate(7) = sqrt( ((rhoLSL(3)+rhoVSL(3))/2.0 - (CritRho+A*(CritT-TsatSL(3))))**2 ) !SMR: changes done for using 4 points instead of 5 when critical calculation
	deviate(8) = sqrt( ((rhoLSL(4)+rhoVSL(4))/2.0 - (CritRho+A*(CritT-TsatSL(4))))**2 )  !SMR: changes done for using 4 points instead of 5 when critical calculation
	!deviate(10) =sqrt( ((rhoLSL(5)+rhoVSL(5))/2.0 - (CritRho+A*(CritT-TsatSL(5))))**2 )  !SMR: changes done for using 4 points instead of 5 when critical calculation

	!write(*,'(14F10.5)') parm(1),parm(2),parm(3),parm(4),deviate(1),deviate(2),deviate(3), &
!deviate(4),deviate(5),deviate(6),deviate(7),deviate(8),deviate(9),deviate(10)

return
end subroutine EvalDevForScalingLaw
	

end subroutine ScalingLaw

subroutine getInterceptSlope(X1,X2,X3,X4,Y1,Y2,Y3,Y4,YINTERCEPT,SLOPE)
	implicit double precision(A-H,O-Z)

	double precision :: xarray(4)
	double precision :: yarray(4)
	
	iCOUNT = 0
	SUMX = 0
	SUMX2 = 0
	SUMY = 0
	SUMXY = 0

	xarray(1) = X1
	xarray(2) = X2
	xarray(3) = X3
	xarray(4) = X4

	yarray(1) = Y1
	yarray(2) = Y2
	yarray(3) = Y3
	yarray(4) = Y4
	
	do i=1,4
		iCOUNT = iCOUNT + 1
		SUMX = SUMX + xarray(i)
		SUMX2 = SUMX2 + xarray(i) ** 2
		SUMY = SUMY + yarray(i)
		SUMXY = SUMXY + xarray(i) * yarray(i)
	enddo

 
	XMEAN = SUMX / iCOUNT
	YMEAN = SUMY / iCOUNT
	SLOPE = (SUMXY - SUMX * YMEAN) / (SUMX2 - SUMX * XMEAN)
	YINTERCEPT = YMEAN - SLOPE * XMEAN

	!B2 = YINTERCEPT
	!B3 = SLOPE
end subroutine getInterceptSlope

double precision function QuadExtrapolate(x01,y01,x02,y02,x03,y03,xvalue)
implicit none
integer,parameter::n=3 
double precision:: x01,y01,x02,y02,x03,y03,xvalue
double precision:: yvalue
real,dimension (n)::b,x 
real,dimension(n,n)::a,a1 
integer::i,j,k,l
real::z
a1(1,1)=1.0d0
a1(1,2)=0.0d0
a1(1,3)=0.0d0
a1(2,1)=0.0d0
a1(2,2)=1.0d0
a1(2,3)=0.0d0
a1(3,1)=0.0d0
a1(3,2)=0.0d0
a1(3,3)=1.0d0

a(1,1)=x01**2
a(1,2)=x01
a(1,3)=1.d0
a(2,1)=x02**2
a(2,2)=x02
a(2,3)=1.d0
a(3,1)=x03**2
a(3,2)=x03
a(3,3)=1.d0
b(1)=y01
b(2)=y02
b(3)=y03

!divided all elements of a & a1 by a(i,i) 
do i=1,n
	z=a(i,i) 
	do j=1,n
		a(i,j)=a(i,j)/z
		a1(i,j)=a1(i,j)/z 
	enddo
	!make zero all entries in column a(j,i) & a1(j,i) 
	do j=i+1,n
	z=a(j,i) 
	do k=1,n
		a(j,k)=a(j,k)-z*a(i,k)
		a1(j,k)=a1(j,k)-z*a1(i,k)
	enddo
	enddo
enddo
!subtract appropiate multiple of row j from j-1 
do i=1,n-1
	do j=i+1,n 
	z=a(i,j) 
		do l=1,n
			a(i,l)=a(i,l)-z*a(j,l) 
			a1(i,l)=a1(i,l)-z*a1(j,l) 
		enddo
	enddo 
enddo
do i=1,n 
	do j=1,n 
		x(i)=0 
		do k=1,n
			x(i)=x(i)+a1(i,k)*b(k)
		enddo
	enddo
enddo

yvalue=x(1)*xvalue**2+x(2)*xvalue+x(3)
QuadExtrapolate=yvalue

end function QuadExtrapolate

double precision function TsatFinder(zLiq,x01,y01,x02,y02,x03,y03)
implicit none
integer,parameter::n=3 
double precision:: zliq,x01,y01,x02,y02,x03,y03,xvalue
!double precision:: yvalue
real,dimension (n)::b,x 
real,dimension(n,n)::a,a1 
integer::i,j,k,l
real::z
a1(1,1)=1.0d0
a1(1,2)=0.0d0
a1(1,3)=0.0d0
a1(2,1)=0.0d0
a1(2,2)=1.0d0
a1(2,3)=0.0d0
a1(3,1)=0.0d0
a1(3,2)=0.0d0
a1(3,3)=1.0d0

a(1,1)=x01**2
a(1,2)=x01
a(1,3)=1.d0
a(2,1)=x02**2
a(2,2)=x02
a(2,3)=1.d0
a(3,1)=x03**2
a(3,2)=x03
a(3,3)=1.d0
b(1)=y01
b(2)=y02
b(3)=y03

!divided all elements of a & a1 by a(i,i) 
do i=1,n
	z=a(i,i) 
	do j=1,n
		a(i,j)=a(i,j)/z
		a1(i,j)=a1(i,j)/z 
	enddo
	!make zero all entries in column a(j,i) & a1(j,i) 
	do j=i+1,n
	z=a(j,i) 
	do k=1,n
		a(j,k)=a(j,k)-z*a(i,k)
		a1(j,k)=a1(j,k)-z*a1(i,k)
	enddo
	enddo
enddo
!subtract appropiate multiple of row j from j-1 
do i=1,n-1
	do j=i+1,n 
	z=a(i,j) 
		do l=1,n
			a(i,l)=a(i,l)-z*a(j,l) 
			a1(i,l)=a1(i,l)-z*a1(j,l) 
		enddo
	enddo 
enddo
do i=1,n 
	do j=1,n 
		x(i)=0 
		do k=1,n
			x(i)=x(i)+a1(i,k)*b(k)
		enddo
	enddo
enddo
xvalue=(-1.00*x(2)-SQRT(x(2)**2-4.00*x(1)*(x(3)-zLiq)))/(2.00*(x(1))) !## What happens if I modify QT to use T instead of  1000/T? (negative sign)
!yvalue=x(1)*xvalue**2+x(2)*xvalue+x(3)
TsatFinder=1000.d0/xvalue !## What happens if I modify QT to use T instead of  1000/T?
end function TsatFinder


subroutine DipprTfinder(CASN,Wanted,Tkelvin,value,Units)
	implicit double precision(A-H,O-Z)
	character(len=*) :: CASN,Wanted,Units
	double precision, intent(out) :: Tkelvin
	double precision, intent(in) :: Value

	call MaxMinT(CASN,Wanted,Tmin,Tmax)
	maxIterLoop1=100
	maxIterLoop2=10000
	tol=0.00001
	Tinc=10
	Target=value
	call Dippr(CASN,Wanted,Tmin,ValueAtTmin,Units)
	call Dippr(CASN,Wanted,Tmax,ValueAtTmax,Units)
	call Dippr(CASN,Wanted,Tmin,Estimate,Units)	!initial guess of Estimate
	if( (ValueAtTmax .lt. ValueAtTmin .AND. (value .gt. ValueAtTmin .OR. value .lt. ValueAtTmax)) &
		.OR. &
	    (ValueAtTmax .gt. ValueAtTmin .AND. (value .lt. ValueAtTmin .OR. value .gt. ValueAtTmax)) ) then
		write(*,'(A,F15.5,1x,A,A)') "Error: The temperature corresponding to entered value : ",value,Units," "
		write(*,'(A,F8.2,A,F8.2,A)') "is beyond DIPPR allowed range: ",Tmin," K to ",Tmax," K"
		write(*,'(A,F15.5,1x,A,A,F15.5,1x,A)') "Pick a number between: ",ValueAtTmin,Units," and ",ValueAtTmax,Units
		stop 
	endif
	icount=0
loop1: do j=1,maxIterLoop1

	loop2: do i=1,maxIterLoop2
			icount=icount+1
			Tin = Tmin + i * Tinc
			dev_before=(Estimate-Target)/Target*100
			call Dippr(CASN,Wanted,Tin,Estimate,Units)
			dev_after=(Estimate-Target)/Target*100
			if(dev_before*dev_after .le. 0.d0) then
				!write(*,'(3I5,1x,10F20.10)') icount,i,j,Tinc,Tin,Estimate,target,dev_before,dev_after
				exit loop2
			endif
			!write(*,'(3I5,1x,10F20.10)') icount,i,j,Tinc,Tin,Estimate,target,dev_before,dev_after
		enddo loop2
		if(abs(dev_after) .le. tol) then
			!write(*,*) "Answer is:", Tin
			exit loop1
		endif
		Tinc = -1.d0*Tinc/10.0
		Tmin=Tin
	enddo loop1
	Tkelvin = Tin
end subroutine DipprTfinder

subroutine MaxMinT(CASN,PropID,Tmin,Tmax)

	implicit double precision(A-H,O-Z)
	character :: dumString*155,TorF*8,dumUnits*11
	character :: dStr*80,dipFile*80,ChemID*50,TdepProps*500,Constants*500,Want*50,Chem_Info*500
	character, dimension(100,3) :: ChemInfo*50
	character, dimension(100,11) :: Coefs*50
	character, dimension(1000,4) :: Const*50
	character(len=*) :: CASN
	character(len=*) :: PropID
  	CHARACTER(32) :: login
  	CALL GETLOG(login)

	dipfile=trim(CASN)//".dip"
	dipfile="/home/"//trim(login)//"/Dippr/CASN/"//trim(CASN)//".dip"
	open(1,file=dipfile)
		read(1,*)dStr,nLines 
		read(1,*)
		do i=1,nLines
 			read(1,*,iostat=iErr) ChemInfo(i,1),ChemInfo(i,2),ChemInfo(i,3),dStr
			if(ChemInfo(i,2).eq.CASN) ChemID=ChemInfo(i,3)
		enddo
		read(1,*)dStr,nLines 
		read(1,*)
		do i=1,nLines
 			read(1,*,iostat=iErr)Const(i,1),dStr,Const(i,2),dStr,dStr,Const(i,3),dStr,dStr,dStr,dStr,dStr,dStr,Const(i,4),dStr
		enddo
		read(1,*)dStr,nLines 
		read(1,*)
		do i=1,nLines
			read(1,*,iostat=iErr)Coefs(i,1),Coefs(i,2),dStr,dStr,Coefs(i,3),Coefs(i,4),Coefs(i,5),Coefs(i,6), &
Coefs(i,7),Coefs(i,8),Coefs(i,9),Coefs(i,10),dStr,Coefs(i,11),dStr,dStr,dStr,dStr,dStr,dStr,dStr

		enddo
	close(1)

	do i=1,nLines

		if(Coefs(i,2).eq.PropID) then
			read(Coefs(i,10),*)Tmin
			read(Coefs(i,11),*)Tmax
			exit	!Issue Resolved: In water dippr file, there was two records for LDN Coef_set A was correct and B was wrong
				!exit was added to exit the loop when the first record is read. It migt not be the best way. Careful!
		endif
	enddo


end subroutine MaxMinT
subroutine Dippr(CASN,Wanted,Tkelvin,value,Units)
	implicit double precision(A-H,O-Z)
	character :: dumString*155,TorF*8,dumUnits*11
	character :: dStr*80,dipFile*80,ChemID*50,TdepProps*500,Constants*500,Want*50,Chem_Info*500
	character, dimension(100,3) :: ChemInfo*50
	character, dimension(100,11) :: Coefs*50
	character, dimension(1000,4) :: Const*50
	character, dimension(1000,2) :: Dimension*50
	character, dimension(1000,4) :: Conversion*50
	character(len=*) :: CASN,Wanted,Units
	double precision, intent(in) :: Tkelvin
	double precision, intent(out) :: Value
  	CHARACTER(32) :: login
  	CALL GETLOG(login)

	dipFile="PropUnitID.dip"
	dipFile="/home/"//trim(login)//"/Dippr/Database/PropUnitID.dip"
	open(2,file=dipFile)
		read(2,*,iostat=ioErr)
		if(ioErr.ne.0)write(*,*)  'Dippr: error reading 1st line of PropUnitID.dip' 
		do i=1,51
			read(2,'(a155)',iostat=ioErr)dumString
			read(dumString,*,iostat=ioErr)Dimension(i,1),dStr,dumUnits,TorF,Value,Dimension(i,2)
			if(ioErr.ne.0)write(*,*)' line ',TRIM(dumString)
			if(ioErr.ne.0)write(*,*)'i,line',i,' ',TRIM(Dimension(i,1)),TRIM(dStr),TRIM(dumUnits),TRIM(TorF),Value,TRIM(Dimension(i,2))
			if(ioErr.ne.0)write(*,*)  'Dippr: error reading ith line of PropUnitID.dip' 
			!write(*,*)trim(Dimension(i,1))," ",trim(Dimension(i,2))
		enddo
		read(2,*,iostat=ioErr)
			if(ioErr.ne.0)write(*,*)  'Dippr: error reading 52nd line of PropUnitID.dip' 
		read(2,*,iostat=ioErr)
			if(ioErr.ne.0)write(*,*)  'Dippr: error reading 53rd line of PropUnitID.dip' 
		do i=1,140	!Here we read the conversion factor from standard units into the units of interest. 
			read(2,*,iostat=ioErr)Conversion(i,1),dStr,Conversion(i,2),Conversion(i,3),Conversion(i,4),dStr,dStr
			if(ioErr.ne.0)write(*,*)  'Dippr: error reading i+53th line of PropUnitID.dip' 
			!write(*,*)trim(Conversion(i,1))," ",trim(Conversion(i,2))," ",trim(Conversion(i,3))," ",trim(Conversion(i,4))
		enddo

	close(2)
	!write(*,*)  'PropUnitID read ok.'
	dipfile=trim(CASN)//".dip"
	dipfile="/home/"//trim(login)//"/Dippr/CASN/"//trim(CASN)//".dip"
	open(1,file=dipfile)
		read(1,*)dStr,nLines 
		read(1,*)
		do i=1,nLines
 			read(1,*,iostat=iErr) ChemInfo(i,1),ChemInfo(i,2),ChemInfo(i,3),dStr
			if(ChemInfo(i,2).eq.CASN) ChemID=ChemInfo(i,3)
		enddo
		read(1,*)dStr,nLines 
		read(1,*)
		do i=1,nLines
 			read(1,*,iostat=iErr)Const(i,1),dStr,Const(i,2),dStr,dStr,Const(i,3),dStr,dStr,dStr,dStr,dStr,dStr,Const(i,4),dStr
		enddo
		read(1,*)dStr,nLines 
		read(1,*)
		do i=1,nLines
			read(1,*,iostat=iErr)Coefs(i,1),Coefs(i,2),dStr,dStr,Coefs(i,3),Coefs(i,4),Coefs(i,5),Coefs(i,6), &
Coefs(i,7),Coefs(i,8),Coefs(i,9),Coefs(i,10),dStr,Coefs(i,11),dStr,dStr,dStr,dStr,dStr,dStr,dStr

		enddo
	close(1)
	!write(*,*)  'dipfile ok'
	Chem_Info=",CASN,CNAM,FAM,FORM,INAM,NAME,SMIL,STRU,SYN,"
	TdepProps=",HVP,ICP,LCP,LDN,LTC,LVS,SCP,SDN,ST,STC,SVP,SVR,VDN,VP,VTC,VVS,"
	Constants=",ACEN,AIT,DM,ENT,FLTL,FLTU,FLVL,FLVU,FP,GFOR,GSTD,HCOM,HFOR,HFUS,&
			HSTD,HSUB,LVOL,MP,MW,NBP,OPT,PAR,PC,RG,RI,SOLP,SSTD,SYM,TC,TPP,TPT,VC,VDWA,VDWV,ZC,"
	Want=","//trim(Wanted)//","
	if(index(Constants,trim(Want)).ne.0.AND.index(TdepProps,trim(Want)).eq.0.AND. &
		index(Chem_Info,trim(Want)).eq.0)  then
		x=DipprConst(ChemID,Wanted)
		Value=Convert(ChemID,x,Units,Wanted,Tkelvin)
	elseif(index(TdepProps,trim(Want)).ne.0.AND.index(Constants,trim(Want)).eq.0.AND. &
		index(Chem_Info,trim(Want)).eq.0)  then
		y=DipprValue(ChemID,Wanted,Tkelvin)
		Value=Convert(ChemID,y,Units,Wanted,Tkelvin)
	elseif(index(Chem_Info,trim(Want)).ne.0.AND.index(TdepProps,trim(Want)).eq.0.AND. &
		index(Constants,trim(Want)).eq.0) then
		Units=DipprInfo(ChemID,Wanted)
		!write(*,*)DipprInfo(ChemID,Wanted)
		value=0.0
	endif

contains !the following are defined as member functions of dippr

double precision function DipprValue(ChemID,PropID,T)
	implicit double precision(A-H,O-Z)
	character(len=*) :: ChemID,PropID
 	double precision :: T,Coefficient(5)
	Coefficient=0.0
	
	do i=1,100

		if(Coefs(i,2).eq.PropID) then
			read(Coefs(i,10),*)Tmin
			read(Coefs(i,11),*)Tmax
			!write(*,*) Tmin,Tmax
			if(T.lt.Tmin.OR.T.gt.Tmax) then 
				write(*,'(A18,A3,A16,F6.1,A26,F6.1,A6,F7.2,A3)') &
				'DIPPR Warning: In ',PropID,' calculation, T=',T,' is beyond allowed range (',Tmin,' K to ',Tmax,' K)'

				!SMR 6/30/17: These three lines will force the property to be zero if the T is beyond
				!	      the allowed range. 	

				!write(*,*)"zero will be returned instead!"	
				!DipprValue = 0.0
				!return
			endif
				
			read(Coefs(i,4),*)nCoef
		
			do j=1,nCoef
				read(Coefs(i,j+4),*)Coefficient(j)
			enddo
			A=Coefficient(1)
			B=Coefficient(2)
			C=Coefficient(3)
			D=Coefficient(4)
			E=Coefficient(5)
			!write(*,*) A,B,C,D,E
			if(Coefs(i,3).eq."100") Eq = A+B*T+C*T**2+D*T**3+E*T**4
			if(Coefs(i,3).eq."101") Eq = EXP(A+B/T+C*LOG(T)+D*T**E)
			if(Coefs(i,3).eq."102") Eq = A*T**B/(1+C/T+D/T**2)
			if(Coefs(i,3).eq."103") Eq = A+B*EXP(-C/T**D)
			if(Coefs(i,3).eq."104") Eq = A+B/T+C/T**3+D/T**8+E/T**9
			if(Coefs(i,3).eq."105") Eq = A/B**(1+(1-T/C)**D)
			if(Coefs(i,3).eq."106") then
				TR=T/DipprConst(ChemID,"TC")
				Eq = A*(1-TR)**(B+C*TR+D*Tr**2+E*Tr**3)
			endif
			if(Coefs(i,3).eq."107") Eq = A+B*((C/T)/SINH(C/T))**2+D*((E/T)/COSH(E/T))**2
			if(Coefs(i,3).eq."114") then
				TAU=(1.d0-T/DipprConst(ChemID,"TC"))
				Eq = A**2/TAU+B-2*A*C*TAU-A*D*TAU**2-1/3*C**2*TAU**3-.5*C*D*TAU**4-1/5*D**2
			endif
			if(Coefs(i,3).eq."115") Eq = EXP(A+B/T+C*LOG(T)+D*T**2+E/T**2)
			if(Coefs(i,3).eq."116") then !this is water
				TAU=(1.d0-T/DipprConst(ChemID,"TC"))
				Eq = A+B*TAU**.35d0+C*TAU**(2.d0/3)+D*TAU+E*TAU**(4.d0/3)
			endif
			exit
		endif

	enddo

	DipprValue=Eq
end function DipprValue

double precision function DipprConst(ChemID,PropID)
	implicit double precision(A-H,O-Z)
	character(len=*) :: ChemID,PropID
	notFound=1
	do i=1,1000
		if(Const(i,2).eq.PropID .AND. Const(i,4).eq. "A") then
			notFound=0
			read (Const(i,3), *) DipNum
			exit
		endif
	enddo
	if(notFound.ne.0)write(*,*)  'DipprConst: value not found'
	DipprConst=DipNum
end function DipprConst

 character* 50 function DipprInfo(ChemID,PropID)
	implicit double precision(A-H,O-Z)
	character(len=*), intent(in) :: ChemID,PropID
	do i=1,100
		if(ChemInfo(i,2).eq.PropID) then
		DipprInfo=ChemInfo(i,3)
		exit
		endif
	enddo

end function DipprInfo

double precision function Convert(ChemID,value,Units,PropID,T)
	implicit double precision(A-H,O-Z)
	character(len=*) :: ChemID,Units,PropID
 	double precision :: T,value
	do i=1,1000
		if(Dimension(i,1).eq.PropID) then
			notFound=1
			do j=1,1000
				if(Dimension(i,2).eq.Conversion(j,1).AND.Conversion(j,2).eq.Units) then
					read (Conversion(j,3), *) Convert
					if(Conversion(j,4).eq."NA") Convert=value*Convert
					if(Conversion(j,4).eq."%MW") Convert=value*Convert/DipprConst(ChemID,"MW")
					if(Conversion(j,4).eq."*MW") Convert=value*Convert*DipprConst(ChemID,"MW")
					if(Conversion(j,4).eq."-MW") Convert=value*Convert*DipprConst(ChemID,"MW")
					if(Conversion(j,4).eq."Cel2K") Convert=value-273.15
					if(Conversion(j,4).eq."Far2K") Convert=value*9.0/5.0-459.67
					if(Conversion(j,4).eq."%MW%LDN") Convert=value*Convert/DipprConst(ChemID,"MW")/DipprValue(ChemID,"LDN",T)
					!write(*,*) Convert,DipprConst(ChemID,"MW"),DipprValue(ChemID,"LDN",T) !Conversion(j,3),value
					notFound=0
					goto 111
				endif
			enddo
			if(notFound.ne.0)write(*,*)  'conversion factor not found. applying raw value.'
		endif
	enddo
111 continue
	if(abs(Convert) < 1e-11)then
		write(*,*)'Input:',ChemID,value,Units,PropID
		write(*,*)  'Dippr:Convert: converted value is zero'
	endif
end function Convert

end subroutine Dippr
