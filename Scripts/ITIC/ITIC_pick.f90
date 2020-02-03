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
logical isLammps,isGromscs,doesVirialCalcITpointsExist,doesVirialCalcIT2pointsExist,isCriticalNeeded, isMoleculeUnknown
logical isLinearuDepT,isQU,isLU,isLT,isQT
logical isMixedLQ,isMixedLQ2,isThereB2ITHardCoded,isB2FromDippr,isConvergencePathNeeded
double precision :: Tfile(nMaxData),rhofile(nMaxData),Pfile(nMaxData),Zfile(nMaxData),Zstdfile(nMaxData), &
	ePotfile(nMaxData),eBondfile(nMaxData),eVdwfile(nMaxData),eIntraVdwfile(nMaxData),simTimefile(nMaxData),eqTimefile(nMaxData)

double precision :: Uresfile(nMaxData), UresStdfile(nMaxData)
double precision :: Ures_IT(20), Uresstd_IT(20)
double precision :: Ures_IT_vr(20), Uresstd_IT_vr(20), Ures_IT_vr2(20), Uresstd_IT_vr2(20)
double precision :: Ures_IC(maxICs,maxICTs), Uresstd_IC(maxICs,maxICTs)		

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

maxTolerance = 1.0d0

isMoleculeUnknown = .false.

isMixedLQ = .false.
isMixedLQ2 = .true.

isLT = .true.
isQT = .false.

isLU = .false.
isQU = .true.

isLinearuDepT = .false.

isThereB2ITHardCoded = .false.

isB2FromDippr=.false.

call getarg(1,arg1)
call getarg(2,arg2)
call getarg(3,arg3)
call getarg(4,arg4)

if(trim(arg1).eq."man".OR.trim(arg1).eq."MAN") then
	write(*,*) "Manual:"
stop
endif

CASN=arg1

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
