using MatrixMarket
using DistributedArrays
using SparseMatricesCSR
using SparseArrays

using MPI
MPI.Init()

comm = MPI.COMM_WORLD

function read_and_send_matrix(filename)
  rank = MPI.Comm_rank(comm)
  world = MPI.Comm_size(comm)
  if rank == 0
    G = MatrixMarket.mmread(filename, :csr)
    n = size(G, 1)
    nb_sub = world
    Is = Array{Array{Int}}(undef, nb_sub)
    Js = Array{Array{Int}}(undef, nb_sub)
    shapes     = [div(n, nb_sub) for _ in 1:nb_sub]
    shapes[nb_sub] = n - (nb_sub-1)*div(n, nb_sub)
    offsets = zeros(nb_sub)
    offsets[2:nb_sub] = cumsum(shapes)[1:nb_sub-1]
    for k in 1:nb_sub
      Is[k] = []
      Js[k] = []
    end
    for row_id in 1:(length(G.rowptr) - 1)
      next_ptr = G.rowptr[row_id + 1]
      current_ptr = G.rowptr[row_id]
      k = div((row_id - 1), div(n, nb_sub)) + 1
      if k > nb_sub
        k = nb_sub
      end
      nb_elements = next_ptr - current_ptr
      append!(Is[k], fill(row_id - offsets[k], nb_elements))
      append!(Js[k], G.colval[current_ptr:next_ptr-1])
    end

    for k in 2:nb_sub
      MPI.send(n, comm; dest=k-1, tag=0)
      MPI.send(Is[k], comm; dest=k-1, tag=1)
      MPI.send(Js[k], comm; dest=k-1, tag=2)
      MPI.send(shapes[k], comm; dest=k-1, tag=3)
    end
    Gs = sparsecsr(Is[1], Js[1], ones(length(Is[1])), shapes[1], n)
    return Gs
  else

    n = MPI.recv(comm; source=0, tag=0)
    Is = MPI.recv(comm; source=0, tag=1)
    Js = MPI.recv(comm; source=0, tag=2)
    shape = MPI.recv(comm; source=0, tag=3)
    Gs = sparsecsr(Is, Js, ones(length(Is)), shape, n)
    return Gs
  end
end

function pagerank(filename, maxi)
  G = read_and_send_matrix(filename)
  rank = MPI.Comm_rank(comm)
  world = MPI.Comm_size(comm)

  n = size(G, 2)
  p = ones(n)
  alpha = 0.85
  one_minus_alpha = 1 - alpha

  sizes = [div(n, world) for _ in 1:world]
  sizes[world] = n - (world-1) * div(n, world)
  offsets = zeros(Int64, world)
  offsets[2:world] = cumsum(sizes)[1:world-1]

  start = time_ns()
  for iter in 1:maxi
    p_partial = alpha * (G * p) + one_minus_alpha * p[1+offsets[rank + 1]:(1+offsets[rank + 1] + sizes[rank + 1] - 1)]
    sum_partial = sum(p_partial)
    sum_total = MPI.Allreduce(sum_partial, +, comm)
    p_partial = p_partial / sum_total
    p_g = VBuffer(p, sizes)
    MPI.Allgatherv!(p_partial, p_g, comm)
  end
  fin = time_ns()
  if rank == 0
    println((fin - start) * 1e-9)
    println(p[1])
  end
end

@assert(length(ARGS) == 1)
filename = ARGS[1]
maxi = 250
pagerank(filename, maxi)

