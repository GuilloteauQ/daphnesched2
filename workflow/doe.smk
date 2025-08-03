DAPHNE_GIT_URL    = "https://github.com/daphne-eu/daphne"
DAPHNE_GIT_COMMIT = "00419aa8313ae72b55306ac8c14d060c115df40c"
DAPHNE_DOCKER_TAG = "2025-03-12_X86-64_BASE_ubuntu24.04"
JUPYCPP_DOCKER_TAG = "july25"

LANGUAGES = [
  "cpp",
  "py",
  "daph",
  "jl"
]

MATRICES = [
  "amazon0601",
  "wikipedia-20070206",
  # "ljournal-2008"
]

MATRICES_CONFIG = [
  "amazon0601",
  "wikipedia-20070206",
]

SCRIPTS_MPI = [
  "pagerank",
  #"connected_components"
]

SCRIPTS_WITH_MATRICES = [
  "connected_components",
  "pagerank",
  #"bfs",
  #"triangle_count"
]

SCRIPTS_WITHOUT_MATRICES = [
  "nbody"
]

NUM_THREADS = [
  1,
  64,
  128
]

MPI_CONFIG_NB_NODES=4
MPI_CONFIG_CORES_PER_NODE=20

MPI_SCALE_NB_NODES = range(1, 11)

MPI_DISTRIBUTION = {
  # total-mpi-procs, task-per-node, cpu-per-task
  "4":  (1,  20),
  "8":  (2,  10),
  "16": (4,  5),
  "20": (5,  4),
  "40": (10, 2),
  "80": (20, 1)
}


TOTAL_ITERS = 5
ITERATIONS = range(1, TOTAL_ITERS + 1)

SCHEMES = [
  "STATIC",
  "GSS",
  "AUTO",
  "VISS",
  # "SS",
  "TSS",
  "FAC2",
  "TFSS",
  "FISS",
  "PLS",
  "MSTATIC",
  "MFSC",
  "PSS",
]

QUEUE_LAYOUTS = [
  "CENTRALIZED",
  "PERGROUP",
  "PERCPU"
]
