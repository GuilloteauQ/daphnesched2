# To Run

## Sequential

```console
julia --project=. pagerank.jl ../../../matrices/amazon0601/amazon0601_ones.mtx
```

## Parallel

```console
OMP_NUM_THREADS=12 julia --threads 12 --project=. pagerank.jl ../../../matrices/amazon0601/amazon0601_ones.mtx
```
