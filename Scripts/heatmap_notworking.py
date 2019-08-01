


import numpy as np
import matplotlib.pyplot as plt

data_file = "0.5Z_0.5U_all.txt"
sig = np.loadtxt(data_file, usecols=0)
eps = np.loadtxt(data_file, usecols=1)
score = np.loadtxt(data_file, usecols=2)

sig = np.unique(sig)
eps = np.unique(eps)

print(sig)
print(eps)
sig, eps = np.meshgrid(sig, eps)

score = np.reshape(score, [len(eps), len(sig)]) ##a + b # Vectorize your cost function

fig, ax = plt.subplots()
im = ax.pcolormesh(sig, eps, score)
fig.colorbar(im)

ax.axis('tight')
plt.show()