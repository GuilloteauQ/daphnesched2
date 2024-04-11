LANGUAGES = [
  "cpp",
  "py",
  "daph",
  "jl"
]

MATRICES = [
  "amazon0302",
  "amazon0601",
  "wikipedia-20070206",
  "ljournal-2008"
]

SCRIPTS_WITH_MATRICES = [
  "connected_components",
  "pagerank",
  "bfs",
  # "triangle_count"

]

SCRIPTS_WITHOUT_MATRICES = [
  "nbody"
]

NUM_THREADS = [
  1,
  20
]

TOTAL_ITERS = 3
ITERATIONS = range(1, TOTAL_ITERS + 1)
