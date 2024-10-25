import sys
import time
import numpy as np
from scipy.io import mmread
from math import floor

def bfs(filename, maxi=2000):
    start_reading = time.time()
    G = mmread(filename)
    start_compute = time.time()
    n = G.shape[0]
    x = np.zeros(n)
    x[0] = 1.0
    one = np.ones(n)

    for iter in range(maxi):
        x = np.minimum(1.0, x + G.dot(x))
    fin = time.time()
    duration_reading = fin - start_reading
    duration_compute = fin - start_compute
    print(f"{duration_reading},{duration_compute},{floor(x.sum())}")

if __name__ == "__main__":
    args = sys.argv
    assert len(args) == 2
    filename = args[1]
    bfs(filename)
