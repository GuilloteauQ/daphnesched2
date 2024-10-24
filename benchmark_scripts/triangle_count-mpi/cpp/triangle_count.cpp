#include <iostream>
#include <Eigen/SparseCore>
#include <Eigen/Dense>
#include <Eigen/Sparse>
#include <Eigen/Core>
#include <unsupported/Eigen/SparseExtra>
#include <chrono>
#include <mpi.h>
#include <iomanip>

typedef Eigen::SparseMatrix<double, Eigen::ColMajor> SpMatC;
typedef Eigen::SparseMatrix<double, Eigen::RowMajor> SpMatR;
typedef Eigen::Triplet<double> T;

SpMatR read_and_send_matrix(std::string filename, int n) {
  int world;
  int rank;
  MPI_Comm_size(MPI_COMM_WORLD, &world);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);

  if (rank == 0) {
    SpMatR G(n, n); 
    if (!loadMarket(G, filename))
      std::cout << "could  not load mtx file" << std::endl;

    int nb_sub = world;

    std::vector<T> content;
    std::vector<T> content0;
    std::vector<int> sizes;
    content.resize(G.nonZeros());
    content0.resize(G.nonZeros());
    sizes.resize(nb_sub);
    for (int i = 0; i < nb_sub; i++) {
      sizes[i] = n / nb_sub;
    }
    sizes[nb_sub - 1] = n - (nb_sub-1) * (n / nb_sub);
    int remainder = n % nb_sub;

    int previous_k = 0;
    int k = 0;
    for (int row_id = 0; row_id < G.outerSize(); row_id++) {
      previous_k = k;
      k = row_id / (n / nb_sub); 
      if (k > nb_sub - 1) k = nb_sub - 1;
      if (previous_k != 0 && previous_k != k) {
        int nb_elems = content.size();
        MPI_Send(&sizes[previous_k], 1, MPI_INT, previous_k, 0, MPI_COMM_WORLD);
        MPI_Send(&nb_elems, 1, MPI_INT, previous_k, 1, MPI_COMM_WORLD);
        MPI_Send(&content[0], nb_elems * sizeof(T), MPI_CHAR, previous_k, 2, MPI_COMM_WORLD);
        content.clear();
      }
      for (SpMatR::InnerIterator it(G,row_id); it; ++it)
      {
        if (k == 0) {
          content0.push_back(T(row_id - k * (n/nb_sub), it.col(), it.value()));
        } else {
          content.push_back(T(row_id - k * (n/nb_sub), it.col(), it.value()));
        }
      }
    }
    int nb_elems = content.size();
    MPI_Send(&sizes[nb_sub-1], 1, MPI_INT, nb_sub-1, 0, MPI_COMM_WORLD);
    MPI_Send(&nb_elems, 1, MPI_INT, nb_sub-1, 1, MPI_COMM_WORLD);
    MPI_Send(&content[0], nb_elems * sizeof(T), MPI_CHAR, nb_sub-1, 2, MPI_COMM_WORLD);
    content.clear();
    SpMatR Gs((sizes[0]), n);
    Gs.setFromTriplets(content0.begin(), content0.end());
    return Gs;
  } else {
    int nb_elems = 0;
    int size = 0;
    MPI_Recv(&size, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    MPI_Recv(&nb_elems, 1, MPI_INT, 0, 1, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    std::vector<T> content;
    content.resize(nb_elems);
    MPI_Recv(&content[0], nb_elems*sizeof(T), MPI_CHAR, 0, 2, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    SpMatR Gs(size, n);
    Gs.setFromTriplets(content.begin(), content.end());
    return Gs;
  }
}

int main(int argc, char** argv) {
  MPI_Init(&argc, &argv);
  if (argc != 3) {
    std::cout << "Usage: bin mat.mtx size" << std::endl;
    return 1;
  }
  std::string filename = argv[1];

  int n = atoi(argv[2]);

  int world;
  int rank;
  MPI_Comm_size(MPI_COMM_WORLD, &world);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);

  auto start_reading = std::chrono::high_resolution_clock::now();

  SpMatR G = read_and_send_matrix(filename, n);

  SpMatR GFull(n, n); 
  if (!loadMarket(GFull, filename)) {
    std::cout << "could  not load mtx file" << std::endl;
    return 1;
  }

  auto start_compute = std::chrono::high_resolution_clock::now();

  SpMatR G_square = G * GFull;
  double tmp_nb_triangles = G_square.cwiseProduct(G).sum();

  double nb_triangles = 0.0;

  MPI_Reduce(&tmp_nb_triangles, &nb_triangles, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);

  auto stop = std::chrono::high_resolution_clock::now();
  auto duration_compute = std::chrono::duration<float>(stop - start_compute);
  auto duration_reading = std::chrono::duration<float>(stop - start_reading);
  if (rank == 0) {
    std::cout << duration_reading.count() << "," << duration_compute.count() << "," << std::setprecision (15) << std::floor(nb_triangles / 3.0) << std::endl;
  }
  MPI_Finalize();
  return 0;
}
