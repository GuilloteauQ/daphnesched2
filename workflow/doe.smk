LANGUAGES = [
  "cpp",
  "py",
  "daph",
  #"jl"
]

MATRICES = [
  "amazon0601",
  "wikipedia-20070206"
]

SCRIPTS_WITH_MATRICES = [
  "connected_components",
  "pagerank"
]

SCRIPTS_WITHOUT_MATRICES = [
  "nbody"
]

NUM_THREADS = [
  1,
  20
]

TOTAL_ITERS = 5
ITERATIONS = range(1, TOTAL_ITERS + 1)
