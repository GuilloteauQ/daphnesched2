LANGUAGES = [
  #{"name": "c++",    "ext": "cpp"},
  {"name": "python", "ext": "py"},
  {"name": "daphne", "ext": "daph"}
]

LANGS=list(map(lambda x: x["name"], LANGUAGES))

MATRICES = [
  "amazon0601/amazon0601.mtx"
]

SCRIPTS = [
  "benchmark_scripts/connected_components"
]

NUM_THREADS = [
  1,
  20
]

ITERATIONS = range(1, 5 + 1)
