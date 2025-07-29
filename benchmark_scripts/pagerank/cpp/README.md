# To build

```console
sh build.sh
```

# To run

## Sequential

```console
./pagerank_seq ../../../matrices/amazon0601/amazon0601_ones.mtx 403394
```

## Parallel

```console
OMP_NUM_THREADS=12 ./pagerank_omp ../../../matrices/amazon0601/amazon0601_ones.mtx 403394
```
