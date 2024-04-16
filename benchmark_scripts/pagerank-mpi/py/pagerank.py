from scipy.io import mmread
from scipy.sparse import csr_matrix
import time
import sys
import numpy as np

from mpi4py import MPI

comm = MPI.COMM_WORLD
rank = comm.Get_rank()

def read_and_send_sparse_matrix(filename):
    rank = comm.Get_rank()
    nb_sub = comm.Get_size()
    shape = 0
    n = 0
    Gs = None
    if rank == 0:
        G = csr_matrix(mmread(filename))
        n = G.shape[0]
        print(G.shape)
        fh_indices = []
        fh_indptr  = []
        fh_data    = []
        fh_ptr     = [0 for _ in range(nb_sub)]
        shapes     = [n // nb_sub for _ in range(nb_sub)]
        shapes[-1] = n - sum(shapes[:-1])
        for k in range(nb_sub):
            fh_indices.append([])
            fh_indptr.append([0])
            fh_data.append([])

        remainer = n % nb_sub

        row_id = 0
        while row_id < len(G.indptr) - 1 - remainer:
            next_ptr = G.indptr[row_id + 1]
            current_ptr = G.indptr[row_id]
            k = row_id // (n // nb_sub)
            #print(f"{row_id} -> {k}")
            nb_elements = next_ptr - current_ptr
            indices = G.indices[current_ptr:next_ptr]
            half_indices = [ind for ind in indices]
            fh_indices[k] += half_indices
            fh_ptr[k] += len(indices)
            fh_data[k] += [1.0 for _ in range(len(indices))]
            fh_indptr[k].append(fh_ptr[k])
            row_id += 1

        while row_id < len(G.indptr) - 1:
            next_ptr = G.indptr[row_id + 1]
            current_ptr = G.indptr[row_id]
            k = nb_sub - 1
            #print(f"{row_id} -> {k}")
            nb_elements = next_ptr - current_ptr
            indices = G.indices[current_ptr:next_ptr]
            half_indices = [ind for ind in indices]
            fh_indices[k] += half_indices
            fh_ptr[k] += len(indices)
            fh_data[k] += [1.0 for _ in range(len(indices))]
            fh_indptr[k].append(fh_ptr[k])
            row_id += 1


        for k in range(1, nb_sub):
            G_h = csr_matrix((fh_data[k], fh_indices[k], fh_indptr[k]), shape=(shapes[k], n))
            info = {"n_data": len(fh_data[k]), "n_indices": len(fh_indices[k]), "n_indptr": len(fh_indptr[k]), "shape": shapes[k], "n": n}
            #print(f"{k} -> {info['n_indptr']} -> {np.array(fh_indptr[k])}")
            comm.send(info, dest=k, tag=10)
            #comm.Send(len(fh_data[k]),    dest=k, tag=10)
            #comm.Send(len(fh_indices[k]), dest=k, tag=11)
            #comm.Send(len(fh_indptr[k]),  dest=k, tag=12)
            #comm.Send(fh_shapes[k],       dest=k, tag=13)

            #plop = np.array(fh_indptr[k])
            #print(plop.dtype)
            comm.Send(np.array(fh_indptr[k]),    dest=k, tag=121)
            comm.Send(np.array(fh_data[k]),    dest=k, tag=101)
            comm.Send(np.array(fh_indices[k]), dest=k, tag=111)

        # TODO 0
        data = fh_data[0]
        indices = fh_indices[0]
        indptr = fh_indptr[0]
        shape = shapes[0]
        Gs = csr_matrix((data, indices, indptr), shape=(shape, n))
    else:
        info = comm.recv(source=0, tag=10)
        #print(info)
        n_data = info["n_data"]
        n_indices = info["n_indices"]
        n_indptr = info["n_indptr"]
        shape = info["shape"]
        n = info["n"]

        data = np.empty(n_data, dtype=np.float64)
        indptr = np.zeros(n_indptr, dtype=np.int64)
        indices = np.empty(n_indices, dtype=np.int32)

        comm.Recv(indptr,  source=0, tag=121)
        comm.Recv(data,    source=0, tag=101)
        comm.Recv(indices, source=0, tag=111)

        Gs = csr_matrix((data, indices, indptr), shape=(shape, n))
    #print(f"{rank}:\n{Gs.A}\n\n\n")
    return Gs


def pagerank(filename, maxi=250):
    G = read_and_send_sparse_matrix(filename)
    #G = mmread(filename)
    world = comm.Get_size()
    start = time.time()
    n = G.shape[1]
    p = np.ones(n)
    alpha = 0.85
    one_minus_alpha = 1 - alpha
    sizes = [n // world for _ in range(world)]
    sizes[-1] = n - sum(sizes[:-1])
    offsets = np.zeros(world, dtype=np.int32)
    offsets[1:]=np.cumsum(sizes)[:-1]

    for iter in range(maxi):
        p_partial = alpha * G.dot(p) +one_minus_alpha * p[offsets[rank]:(offsets[rank] + sizes[rank])]

        sum_partial = p_partial.sum()
        sum_total = np.zeros_like(sum_partial)
        MPI.COMM_WORLD.Allreduce(sum_partial, sum_total, op=MPI.SUM)
        p_partial = p_partial / sum_total

        comm.Allgatherv([p_partial,  MPI.DOUBLE],
                       [p, sizes, offsets, MPI.DOUBLE])
    end = time.time()
    if rank == 0:
        print(p[0])
        print(end - start)

if __name__ == "__main__":
    args = sys.argv
    assert len(args) == 2
    filename = args[1]
    pagerank(filename)
