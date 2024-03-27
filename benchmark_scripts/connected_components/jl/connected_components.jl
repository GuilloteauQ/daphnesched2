using MatrixMarket

function cc(filename, maxi)
  G = MatrixMarket.mmread(filename)
  println(typeof(G))
  println(MatrixMarket.mminfo(filename))
  start = time()
  c = collect(1.0:1.0:float(size(G, 1)))

  for iter in 1:maxi
    x = vec(maximum(G .* transpose(c), dims=2))
    c = max.(c, x)
  end
  fin = time()
  println(fin - start)
end

@assert(length(ARGS) == 1)
filename = ARGS[1]
maxi = 100
cc(filename, maxi)

