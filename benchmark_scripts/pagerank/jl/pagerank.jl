using MatrixMarket

function pagerank(filename, maxi)
  start_reading = time_ns()
  G = MatrixMarket.mmread(filename)
  n = size(G, 1)
  p = ones(n)
  alpha = 0.85
  one_minus_alpha = 1 - alpha

  start_compute = time_ns()
  for iter in 1:maxi
    p = (G * p) * alpha + p * one_minus_alpha
    p = p / sum(p)
  end
  fin = time_ns()
  duration_reading = (fin - start_reading) * 1e-9
  duration_compute = (fin - start_compute) * 1e-9
  println("$(duration_reading),$(duration_compute),$(p[1])")
end

@assert(length(ARGS) == 1)
filename = ARGS[1]
maxi = 250
pagerank(filename, maxi)

