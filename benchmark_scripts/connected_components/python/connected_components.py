import sys
import time
from scipy.io import mmread
from scipy.sparse import coo_array

def cc(filename, maxi=100):
    G = mmread(filename)
    start = time.time()
    c = coo_array(list(map(lambda i: float(i), range(1, G.shape[0] + 1, 1))))

    for iter in range(maxi):
        x = G.multiply(c.transpose()).max(axis=0)
        c = c.maximum(x)
    end = time.time()
    print(end - start)

if __name__ == "__main__":
    args = sys.argv
    assert len(args) == 2
    filename = args[1]
    cc(filename)
