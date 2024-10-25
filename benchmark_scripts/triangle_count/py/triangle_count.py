import sys
import time
from scipy.io import mmread
import numpy as np
from math import floor

filename = sys.argv[1]
start_reading = time.time()
G = mmread(filename)
start_compute = time.time()
G_square = G @ G
nb_triangles = G_square.multiply(G).sum() / 3.0
fin = time.time()
duration_reading = fin - start_reading
duration_compute = fin - start_compute
print(f"{duration_reading},{duration_compute},{floor(nb_triangles)}")
