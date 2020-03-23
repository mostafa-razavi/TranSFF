import numpy
import sys

input_L=sys.argv[1] #'Blk_nvt_BOX_0.dat'
input_V=sys.argv[2] #'Blk_nvt_BOX_1.dat'
Nskip_lines=int(sys.argv[3])
Nblocks = int(sys.argv[4])
avg_or_std = sys.argv[5]

STEPS = numpy.loadtxt(input_L, usecols=(0),skiprows=1)
Nalldata = len(STEPS)      

STEPS_L = numpy.loadtxt(input_L , usecols=(0),skiprows=Nskip_lines)
TOT_EN_L = numpy.loadtxt(input_L , usecols=(1),skiprows=Nskip_lines)
EN_INTER_L = numpy.loadtxt(input_L , usecols=(2),skiprows=Nskip_lines)
EN_TC_L = numpy.loadtxt(input_L , usecols=(3),skiprows=Nskip_lines)
EN_INTRA_B_L = numpy.loadtxt(input_L , usecols=(4),skiprows=Nskip_lines)
EN_INTRA_NB_L = numpy.loadtxt(input_L , usecols=(5),skiprows=Nskip_lines)
EN_ELECT_L = numpy.loadtxt(input_L , usecols=(6),skiprows=Nskip_lines)
EN_REAL_L = numpy.loadtxt(input_L , usecols=(7),skiprows=Nskip_lines)
EN_RECIP_L = numpy.loadtxt(input_L , usecols=(8),skiprows=Nskip_lines)
TOTAL_VIR_L = numpy.loadtxt(input_L , usecols=(9),skiprows=Nskip_lines)
PRESSURE_L = numpy.loadtxt(input_L , usecols=(10),skiprows=Nskip_lines)
TOT_MOL_L = numpy.loadtxt(input_L , usecols=(11),skiprows=Nskip_lines)
TOT_DENS_L = numpy.loadtxt(input_L , usecols=(12),skiprows=Nskip_lines)
HEAT_VAP_L = numpy.loadtxt(input_L , usecols=(13),skiprows=Nskip_lines)

STEPS_V = numpy.loadtxt(input_V , usecols=(0),skiprows=Nskip_lines)
TOT_EN_V = numpy.loadtxt(input_V , usecols=(1),skiprows=Nskip_lines)
EN_INTER_V = numpy.loadtxt(input_V , usecols=(2),skiprows=Nskip_lines)
EN_TC_V = numpy.loadtxt(input_V , usecols=(3),skiprows=Nskip_lines)
EN_INTRA_B_V = numpy.loadtxt(input_V , usecols=(4),skiprows=Nskip_lines)
EN_INTRA_NB_V = numpy.loadtxt(input_V , usecols=(5),skiprows=Nskip_lines)
EN_ELECT_V = numpy.loadtxt(input_V , usecols=(6),skiprows=Nskip_lines)
EN_REAL_V = numpy.loadtxt(input_V , usecols=(7),skiprows=Nskip_lines)
EN_RECIP_V = numpy.loadtxt(input_V , usecols=(8),skiprows=Nskip_lines)
TOTAL_VIR_V = numpy.loadtxt(input_V , usecols=(9),skiprows=Nskip_lines)
PRESSURE_V = numpy.loadtxt(input_V , usecols=(10),skiprows=Nskip_lines)
TOT_MOL_V = numpy.loadtxt(input_V , usecols=(11),skiprows=Nskip_lines)
TOT_DENS_V = numpy.loadtxt(input_V , usecols=(12),skiprows=Nskip_lines)
HEAT_VAP_V = numpy.loadtxt(input_V , usecols=(13),skiprows=Nskip_lines)




Ndata = len(PRESSURE_L)
Nint= int(Ndata/Nblocks)


TOT_EN_L_avg = []
EN_INTER_L_avg = [] 
EN_TC_L_avg = [] 
EN_INTRA_B_L_avg = [] 
EN_INTRA_NB_L_avg = [] 
EN_ELECT_L_avg = [] 
EN_REAL_L_avg = [] 
EN_RECIP_L_avg = [] 
TOTAL_VIR_L_avg = [] 
PRESSURE_L_avg = [] 
TOT_MOL_L_avg = [] 
TOT_DENS_L_avg = [] 
HEAT_VAP_L_avg = [] 
TOT_EN_L_std = []
EN_INTER_L_std = [] 
EN_TC_L_std = [] 
EN_INTRA_B_L_std = [] 
EN_INTRA_NB_L_std = [] 
EN_ELECT_L_std = [] 
EN_REAL_L_std = [] 
EN_RECIP_L_std = [] 
TOTAL_VIR_L_std = [] 
PRESSURE_L_std = [] 
TOT_MOL_L_std = [] 
TOT_DENS_L_std = [] 
HEAT_VAP_L_std = []

TOT_EN_V_avg = []
EN_INTER_V_avg = [] 
EN_TC_V_avg = [] 
EN_INTRA_B_V_avg = [] 
EN_INTRA_NB_V_avg = [] 
EN_ELECT_V_avg = [] 
EN_REAL_V_avg = [] 
EN_RECIP_V_avg = [] 
TOTAL_VIR_V_avg = [] 
PRESSURE_V_avg = [] 
TOT_MOL_V_avg = [] 
TOT_DENS_V_avg = [] 
HEAT_VAP_V_avg = [] 
TOT_EN_V_std = []
EN_INTER_V_std = [] 
EN_TC_V_std = [] 
EN_INTRA_B_V_std = [] 
EN_INTRA_NB_V_std = [] 
EN_ELECT_V_std = [] 
EN_REAL_V_std = [] 
EN_RECIP_V_std = [] 
TOTAL_VIR_V_std = [] 
PRESSURE_V_std = [] 
TOT_MOL_V_std = [] 
TOT_DENS_V_std = [] 
HEAT_VAP_V_std = [] 

for i in range(0,Nblocks):
	From=int(i*Nint)
	To=int((i+1)*Nint)
	#print From,To
	TOT_EN_L_avg.append(numpy.average(TOT_EN_L[From:To]))
	EN_INTER_L_avg.append(numpy.average(EN_INTER_L[From:To])) 
	EN_TC_L_avg.append(numpy.average(EN_TC_L[From:To])) 
	EN_INTRA_B_L_avg.append(numpy.average(EN_INTRA_B_L[From:To])) 
	EN_INTRA_NB_L_avg.append(numpy.average(EN_INTRA_NB_L[From:To])) 
	EN_ELECT_L_avg.append(numpy.average(EN_ELECT_L[From:To])) 
	EN_REAL_L_avg.append(numpy.average(EN_REAL_L[From:To])) 
	EN_RECIP_L_avg.append(numpy.average(EN_RECIP_L[From:To])) 
	TOTAL_VIR_L_avg.append(numpy.average(TOTAL_VIR_L[From:To])) 
	PRESSURE_L_avg.append(numpy.average(PRESSURE_L[From:To])) 
	TOT_MOL_L_avg.append(numpy.average(TOT_MOL_L[From:To])) 
	TOT_DENS_L_avg.append(numpy.average(TOT_DENS_L[From:To])) 
	HEAT_VAP_L_avg.append(numpy.average(HEAT_VAP_L[From:To]))
	TOT_EN_V_avg.append(numpy.average(TOT_EN_V[From:To]))
	EN_INTER_V_avg.append(numpy.average(EN_INTER_V[From:To])) 
	EN_TC_V_avg.append(numpy.average(EN_TC_V[From:To])) 
	EN_INTRA_B_V_avg.append(numpy.average(EN_INTRA_B_V[From:To])) 
	EN_INTRA_NB_V_avg.append(numpy.average(EN_INTRA_NB_V[From:To])) 
	EN_ELECT_V_avg.append(numpy.average(EN_ELECT_V[From:To])) 
	EN_REAL_V_avg.append(numpy.average(EN_REAL_V[From:To])) 
	EN_RECIP_V_avg.append(numpy.average(EN_RECIP_V[From:To])) 
	TOTAL_VIR_V_avg.append(numpy.average(TOTAL_VIR_V[From:To])) 
	PRESSURE_V_avg.append(numpy.average(PRESSURE_V[From:To])) 
	TOT_MOL_V_avg.append(numpy.average(TOT_MOL_V[From:To])) 
	TOT_DENS_V_avg.append(numpy.average(TOT_DENS_V[From:To])) 
	HEAT_VAP_V_avg.append(numpy.average(HEAT_VAP_V[From:To]))

avg_TOT_EN_L = numpy.average(TOT_EN_L_avg)
avg_EN_INTER_L = numpy.average(EN_INTER_L_avg)
avg_EN_TC_L = numpy.average(EN_TC_L_avg)
avg_EN_INTRA_B_L = numpy.average(EN_INTRA_B_L_avg)
avg_EN_INTRA_NB_L = numpy.average(EN_INTRA_NB_L_avg)
avg_EN_ELECT_L = numpy.average(EN_ELECT_L_avg)
avg_EN_REAL_L = numpy.average(EN_REAL_L_avg)
avg_EN_RECIP_L = numpy.average(EN_RECIP_L_avg)
avg_TOTAL_VIR_L = numpy.average(TOTAL_VIR_L_avg)
avg_PRESSURE_L = numpy.average(PRESSURE_L_avg)
avg_TOT_MOL_L = numpy.average(TOT_MOL_L_avg)
avg_TOT_DENS_L = numpy.average(TOT_DENS_L_avg)
avg_HEAT_VAP_L = numpy.average(HEAT_VAP_L_avg)
std_TOT_EN_L = numpy.std(TOT_EN_L_avg)
std_EN_INTER_L = numpy.std(EN_INTER_L_avg)
std_EN_TC_L = numpy.std(EN_TC_L_avg)
std_EN_INTRA_B_L = numpy.std(EN_INTRA_B_L_avg)
std_EN_INTRA_NB_L = numpy.std(EN_INTRA_NB_L_avg)
std_EN_ELECT_L = numpy.std(EN_ELECT_L_avg)
std_EN_REAL_L = numpy.std(EN_REAL_L_avg)
std_EN_RECIP_L = numpy.std(EN_RECIP_L_avg)
std_TOTAL_VIR_L = numpy.std(TOTAL_VIR_L_avg)
std_PRESSURE_L = numpy.std(PRESSURE_L_avg)
std_TOT_MOL_L = numpy.std(TOT_MOL_L_avg)
std_TOT_DENS_L = numpy.std(TOT_DENS_L_avg)
std_HEAT_VAP_L = numpy.std(HEAT_VAP_L_avg)

avg_TOT_EN_V = numpy.average(TOT_EN_V_avg)
avg_EN_INTER_V = numpy.average(EN_INTER_V_avg)
avg_EN_TC_V = numpy.average(EN_TC_V_avg)
avg_EN_INTRA_B_V = numpy.average(EN_INTRA_B_V_avg)
avg_EN_INTRA_NB_V = numpy.average(EN_INTRA_NB_V_avg)
avg_EN_ELECT_V = numpy.average(EN_ELECT_V_avg)
avg_EN_REAL_V = numpy.average(EN_REAL_V_avg)
avg_EN_RECIP_V = numpy.average(EN_RECIP_V_avg)
avg_TOTAL_VIR_V = numpy.average(TOTAL_VIR_V_avg)
avg_PRESSURE_V = numpy.average(PRESSURE_V_avg)
avg_TOT_MOL_V = numpy.average(TOT_MOL_V_avg)
avg_TOT_DENS_V = numpy.average(TOT_DENS_V_avg)
avg_HEAT_VAP_V = numpy.average(HEAT_VAP_V_avg)
std_TOT_EN_V = numpy.std(TOT_EN_V_avg)
std_EN_INTER_V = numpy.std(EN_INTER_V_avg)
std_EN_TC_V = numpy.std(EN_TC_V_avg)
std_EN_INTRA_B_V = numpy.std(EN_INTRA_B_V_avg)
std_EN_INTRA_NB_V = numpy.std(EN_INTRA_NB_V_avg)
std_EN_ELECT_V = numpy.std(EN_ELECT_V_avg)
std_EN_REAL_V = numpy.std(EN_REAL_V_avg)
std_EN_RECIP_V = numpy.std(EN_RECIP_V_avg)
std_TOTAL_VIR_V = numpy.std(TOTAL_VIR_V_avg)
std_PRESSURE_V = numpy.std(PRESSURE_V_avg)
std_TOT_MOL_V = numpy.std(TOT_MOL_V_avg)
std_TOT_DENS_V = numpy.std(TOT_DENS_V_avg)
std_HEAT_VAP_V = numpy.std(HEAT_VAP_V_avg)

if avg_or_std == "avg":
	print(avg_TOT_EN_L, avg_EN_INTER_L, avg_EN_TC_L, avg_EN_INTRA_B_L, avg_EN_INTRA_NB_L, avg_EN_ELECT_L, avg_EN_REAL_L, avg_EN_RECIP_L, avg_TOTAL_VIR_L, avg_PRESSURE_L, avg_TOT_MOL_L, avg_TOT_DENS_L ,avg_HEAT_VAP_L)
	print(avg_TOT_EN_V, avg_EN_INTER_V, avg_EN_TC_V, avg_EN_INTRA_B_V, avg_EN_INTRA_NB_V, avg_EN_ELECT_V, avg_EN_REAL_V, avg_EN_RECIP_V, avg_TOTAL_VIR_V, avg_PRESSURE_V, avg_TOT_MOL_V, avg_TOT_DENS_V ,avg_HEAT_VAP_V)

if avg_or_std == "std":
	print(std_TOT_EN_L, std_EN_INTER_L, std_EN_TC_L, std_EN_INTRA_B_L, std_EN_INTRA_NB_L, std_EN_ELECT_L, std_EN_REAL_L, std_EN_RECIP_L, std_TOTAL_VIR_L, std_PRESSURE_L, std_TOT_MOL_L, std_TOT_DENS_L ,std_HEAT_VAP_L)
	print(std_TOT_EN_V, std_EN_INTER_V, std_EN_TC_V, std_EN_INTRA_B_V, std_EN_INTRA_NB_V, std_EN_ELECT_V, std_EN_REAL_V, std_EN_RECIP_V, std_TOTAL_VIR_V, std_PRESSURE_V, std_TOT_MOL_V, std_TOT_DENS_V ,std_HEAT_VAP_V)