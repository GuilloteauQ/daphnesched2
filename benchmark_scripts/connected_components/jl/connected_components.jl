using MatrixMarket
using SparseArrays

function G_broadcast_mult_c(G, c)
  rows = rowvals(G)
  vals = nonzeros(G)
  m, n = size(G)
  new_vals = Vector{Float64}(undef, length(vals))
  @Threads.threads for j = 1:n
     for i in nzrange(G, j)
        row = rows[i]
        val = vals[i]
        new_vals[i] = val * c[row]
     end
  end
  dropzeros(SparseMatrixCSC(m, n, G.colptr, G.rowval, new_vals))
end

function cc(filename, maxi)
  G = MatrixMarket.mmread(filename)
  start = time_ns()
  c = vec(collect(1.0:1.0:float(size(G, 1))))

  for iter in 1:maxi
    x = maximum(G_broadcast_mult_c(G, c), dims=1)
    c = max.(c, transpose(x))
  end
  fin = time_ns()
  println((fin - start) * 1e-9)
end

@assert(length(ARGS) == 1)
filename = ARGS[1]
maxi = 100
cc(filename, maxi)

