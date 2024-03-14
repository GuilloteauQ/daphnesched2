from scipy.io import mmread
from scipy.sparse import coo_array
import sys

def cc(filename, maxi=40):
    G = mmread(filename)
    c = coo_array(list(map(lambda i: float(i), range(1, G.shape[0] + 1, 1))))

    for iter in range(maxi):
        x = G.multiply(c.transpose()).max(axis=0)
        c = c.maximum(x)
        print(c.sum())

if __name__ == "__main__":
    args = sys.argv
    assert len(args) == 2
    filename = args[1]
    cc(filename)
