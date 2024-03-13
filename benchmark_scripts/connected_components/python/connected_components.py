import numpy as np
from scipy.io import mmread
import sys

def cc(filename, maxi=20):
    G = mmread(filename)
    c = np.arange(1.0, float(G.shape[0] + 1), 1.0)

    for iter in range(maxi):
        x = np.asarray(np.max(G.multiply(np.transpose(c)), axis=1).toarray())
        c = np.maximum(c, x)
        print(np.sum(c))

if __name__ == "__main__":
    args = sys.argv
    assert len(args) == 2
    filename = args[1]
    cc(filename)
