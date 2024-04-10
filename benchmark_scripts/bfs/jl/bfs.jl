using MatrixMarket
using SparseArrays

function main(filename)
  G = mmread(filename)
  n = size(G, 1)
  x = zeros(n)
  x[1] = 1.0
  one = ones(n)

  maxi = 2000
  start = time_ns()
  for iter in 1:maxi
    x = min.(one, x + G * x)
  end
  fin = time_ns()
  println((fin - start) * 1e-9)
end

main(ARGS[1])
