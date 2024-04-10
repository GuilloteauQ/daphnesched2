import sys
import time
from scipy.io import mmread

filename = sys.argv[1]
G = mmread(filename)
start = time.time()
G_square = G.dot(G)
nb_triangles = (G_square.multiply(G)).sum() / 3.0
fin = time.time()
print(fin - start)
