using MatrixMarket
using SparseArrays

start_reading = time_ns()
G = mmread(ARGS[1])
start_compute = time_ns()
G_square = G * G
nb_triangles = sum(G_square .* G) / 3.0
fin = time_ns()
duration_reading = (fin - start_reading) * 1e-9
duration_compute = (fin - start_compute) * 1e-9
println("$(duration_reading),$(duration_compute),$(floor(Int64, nb_triangles))")
