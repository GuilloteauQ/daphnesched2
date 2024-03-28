set -xe

mpic++ -DEIGEN_DONT_PARALLELIZE `pkg-config --cflags eigen3` -O3 -o nbody nbody.cpp
