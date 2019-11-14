# This script plots the MBAR vs true data
# Example:
# python3.6 plot_parity_mbar_vs_dsim.py ALL.scores parity.png EPS2 "0.5336/547.99 0.6937/368.10 691.00/0.2135 691.00/0.5336 691.00/0.6937"

import matplotlib
import numpy
import pandas
import sys
import os
if os.environ.get('DISPLAY','') == '': # then no display found. Use non-interactive Agg backend'
    matplotlib.use('Agg')
import matplotlib.pyplot as plt

data_file = sys.argv[1]              
output_figure_filename = sys.argv[2]        # Output file name
marker_variation_title = sys.argv[3]
T_RHO_PAIR_ARRAY = sys.argv[4].split(" ")

mark_array=["^", ">", "o", "<", "v", "o", "s", ">", "v", "x", "+", "*", "h", "H", "X"]
color_array = ["k", "g", "b", "r", "orange", "c", "yello", "purple"]

# Import data
#T_DSIM RHO_DSIM Z_DSIM Z_std_DSIM Ures_DSIM Ures_std_DSIM N_DSIM T_MABR RHO_MABR Z_MABR Z_std_MABR Ures_MABR Ures_std_MABR N_MABR Neff_MBAR SIG1 EPS1 SIG2 EPS2
df = pandas.read_csv(data_file, sep=' ')

dsim_temp_k = df['T_DSIM']
dsim_rho_gcc = df['RHO_DSIM']
dsim_z = df['Z_DSIM'] 
dsim_z_err = df['Z_std_DSIM'] 
dsim_u_res = df['Ures_DSIM']
dsim_u_res_err = df['Ures_std_DSIM'] 
dsim_nmolec = df['N_DSIM'] 

mbar_temp_k = df['T_MABR'] 
mbar_rho_gcc = df['RHO_MABR'] 
mbar_z = df['Z_MABR'] 
mbar_z_err = df['Z_std_MABR'] 
mbar_u_res = df['Ures_MABR'] 
mbar_u_res_err = df['Ures_std_MABR'] 
mbar_nmolec = df['N_MABR'] 
mbar_neff = df['Neff_MBAR'] 


SIG1 = df['SIG1'] 
EPS1 = df['EPS1'] 
SIG2 = df['SIG2'] 
EPS2 = df['EPS2'] 

dsim_zminus1overRho = ( dsim_z - 1 ) / dsim_rho_gcc
mbar_zminus1overRho = ( mbar_z - 1 ) / mbar_rho_gcc

x1=numpy.linspace(min(dsim_zminus1overRho)-50,max(dsim_zminus1overRho)+50,10) 
x2=numpy.linspace(min(mbar_u_res)-50,max(mbar_u_res)+50,10) 

EPS2_unique = df[marker_variation_title].unique() 

############### Initiate plot #############################################
plt.figure(num=None, figsize=(15, 7), dpi=100, facecolor='w', edgecolor='w')
plt.subplots_adjust(left=0.1, bottom=0.14, right=0.99, top=0.91, wspace=0.3, hspace=None)
font = {'weight' : 'normal', 'size' : 22}
matplotlib.rc('font', **font)    

############### (Z-1)/rho vs. rho plot ##############################

plt.subplot(1, 2, 1 )
plt.xlabel("$(Z-1)/\\rho}$ [$\mathrm{cm^3/g}$] MBAR prediction")
plt.ylabel("$(Z-1)/\\rho}$ [$\mathrm{cm^3/g}$] direct simulation")

for idx in df.index:
    EPS2 = df.iloc[idx, df.columns.get_loc(marker_variation_title)]
    for i in range(0, len(EPS2_unique)):
        if EPS2 == EPS2_unique[i]:
            mark = mark_array[i] 
            print(EPS2)


    T_DSIM = df.iloc[idx,0]
    RHO_DSIM = df.iloc[idx,1]
    for i in range(0, len(T_RHO_PAIR_ARRAY)):
        str1, str2 = T_RHO_PAIR_ARRAY[i].split("/")
        if T_DSIM == float(str1) and RHO_DSIM == float(str2):
            color = color_array[i]
        elif T_DSIM == float(str2) and RHO_DSIM == float(str1):
            color = color_array[i]
        
    #data_label=str(RHO_DSIM) + " $\mathrm{g/cm^3}$" + ", " + str(T_DSIM) + " K"
    plt.scatter(mbar_zminus1overRho[idx], dsim_zminus1overRho[idx], marker=mark, s=200, facecolors="none", edgecolors=color, alpha=1.0)

plt.plot(x1,x1,'k-') # parity line
plt.xlim([-5.5,15])
plt.ylim([-5.5,15])

############### Z vs. 1000/T plot #############################################
plt.subplot(1, 2, 2 )
plt.xlabel("$\hat{U}^\mathrm{res}$ MBAR prediction")
plt.ylabel("$\hat{U}^\mathrm{res}$ direct simulation")

for idx in df.index:
    EPS2 = df.iloc[idx, df.columns.get_loc(marker_variation_title)]
    for i in range(0, len(EPS2_unique)):
        if EPS2 == EPS2_unique[i]:
            mark = mark_array[i] 


    T_DSIM = df.iloc[idx,0]
    RHO_DSIM = df.iloc[idx,1]
    for i in range(0, len(T_RHO_PAIR_ARRAY)):
        str1, str2 = T_RHO_PAIR_ARRAY[i].split("/")
        if T_DSIM == float(str1) and RHO_DSIM == float(str2):
            color = color_array[i]
        elif T_DSIM == float(str2) and RHO_DSIM == float(str1):
            color = color_array[i]
        
    #data_label=str(RHO_DSIM) + " $\mathrm{g/cm^3}$" + ", " + str(T_DSIM) + " K"
    plt.scatter(mbar_u_res[idx], dsim_u_res[idx], marker=mark, s=200, facecolors="none", edgecolors=color, alpha=1.0)

plt.plot(x2,x2,'k-') # parity line
plt.xlim(-19,-2)
plt.ylim(-19,-2)
matplotlib.pyplot.xticks([-5, -10, -15])
matplotlib.pyplot.yticks([-5, -10, -15])

plt.savefig(output_figure_filename)
plt.close()