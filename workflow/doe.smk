LANGUAGES = [
  "cpp",
  "py",
  "daph",
  "jl"
]

MATRICES = [
  #"amazon0302",
  "amazon0601",
  "wikipedia-20070206",
  #"ljournal-2008"
]

SCRIPTS_MPI = [
  "pagerank",
  "connected_components"
]

SCRIPTS_WITH_MATRICES = [
  #"connected_components",
  "pagerank",
  #"bfs",
  # "triangle_count"

]

SCRIPTS_WITHOUT_MATRICES = [
  "nbody"
]

NUM_THREADS = [
  1,
  20
]

MPI_NB_NODES=4
MPI_CORES_PER_NODE=20

MPI_DISTRIBUTION = {
  # total-mpi-procs, task-per-node, cpu-per-task
  "4":  (1,  20),
  "8":  (2,  10),
  "16": (4,  5),
  "20": (5,  4),
  "40": (10, 2),
  "80": (20, 1)
}


TOTAL_ITERS = 3
ITERATIONS = range(1, TOTAL_ITERS + 1)
