import numpy as np
from scipy.io import mmread
import scipy.sparse as ss
import sys

def cc(filename, maxi=40):
    G = mmread(filename)
    c = ss.coo_array(np.arange(1.0, float(G.shape[0] + 1), 1.0))

    for iter in range(maxi):
        x = G.multiply(c.transpose()).max(axis=0)
        c = c.maximum(x)
        print(c.sum())

if __name__ == "__main__":
    args = sys.argv
    assert len(args) == 2
    filename = args[1]
    cc(filename)
