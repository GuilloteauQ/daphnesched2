import numpy as np
from scipy.io import mmread
from scipy.sparse import coo_array
import sys
from math import ceil

def k_core(filename, k):
    G = mmread(filename)
    n = G.shape[0]
    c = np.ones(n)
    x = np.random.rand(n)
    previous = -1 #np.asarray([2 for _ in range(n)])
    #diff = len(np.setdiff1d(previous, c))
    diff = 1

    iter = 0
    while diff != 0:
        prev = c
        x = G.multiply(c.transpose()).sum(axis=0)
        #print(x)
        c = (x >= k).astype(int)
        print(c)

        diff = (c != prev).astype(int).sum()

        iter += 1
        mi = np.min(np.where(x > 0, x, np.inf))
        print(f"{iter}: ({mi}, {x.sum()}) {diff}")

if __name__ == "__main__":
    args = sys.argv
    assert len(args) == 2
    filename = args[1]
    k_core(filename, 2)

