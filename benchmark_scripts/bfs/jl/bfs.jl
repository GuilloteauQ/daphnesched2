using MatrixMarket
using SparseArrays

function G_mult_c(G, c)
  rows = rowvals(G)
  vals = nonzeros(G)
  m, n = size(G)
  result = fill(0.0, n)
  @Threads.threads for j = 1:n
     for i in nzrange(G, j)
        row = rows[i]
        val = vals[i]
        result[row] += val * c[j]
     end
  end
  result
end

function main(filename)
  start_reading = time_ns()
  G = mmread(filename)
  start_compute = time_ns()
  n = size(G, 1)
  x = zeros(n)
  x[1] = 1.0

  maxi = 200
  for iter in 1:maxi
    x = min.(1.0, x .+ G_mult_c(G, x))
  end
  fin = time_ns()
  duration_reading = (fin - start_reading) * 1e-9
  duration_compute = (fin - start_compute) * 1e-9
  println("$(duration_reading),$(duration_compute),$(floor(Int64, sum(x)))")
end

main(ARGS[1])
