using MatrixMarket
using SparseArrays

function cc(filename, maxi)
  G = MatrixMarket.mmread(filename)
  start = time()
  c = vec(collect(1.0:1.0:float(size(G, 1))))

  for iter in 1:maxi
    x = maximum(G .* c, dims=1)
    c = max.(c, transpose(x))
  end
  fin = time()
  println(fin - start)
end

@assert(length(ARGS) == 1)
filename = ARGS[1]
maxi = 100
cc(filename, maxi)

