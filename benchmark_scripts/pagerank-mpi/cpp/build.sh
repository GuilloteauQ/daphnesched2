set -xe


mpic++ pagerank.cpp -o pagerank_omp `pkg-config --cflags eigen3` -O3 -fopenmp -g

#mpic++ pagerank.cpp -o pagerank_seq `pkg-config --cflags eigen3` -O3 -DEIGEN_DONT_PARALLELIZE 
#g++ test.cpp -o test `pkg-config --cflags eigen3` -O3 -DEIGEN_DONT_PARALLELIZE 
