#include <iostream>
#include <Eigen/SparseCore>
#include <Eigen/Dense>
#include <Eigen/Sparse>
#include <Eigen/Core>
#include <unsupported/Eigen/SparseExtra>
#include <chrono>
#include <mpi.h>

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

    std::vector<std::vector<T>> content;
    std::vector<int> sizes;
    content.reserve(nb_sub);
    sizes.reserve(nb_sub);
    for (int i = 0; i < nb_sub; i++) {
      content[i].reserve(G.nonZeros());
      sizes[i] = n / nb_sub;
    }
    sizes[nb_sub - 1] = n - (nb_sub-1) * (n / nb_sub);
    int remainder = n % nb_sub;

    int row_id = 0;
    for (row_id = 0; row_id < G.outerSize() - remainder; row_id++) {
      int k = row_id / (n / nb_sub); 
      for (SpMatR::InnerIterator it(G,row_id); it; ++it)
      {
        content[k].push_back(T(row_id - k * (n/nb_sub), it.col(), it.value()));
      }
    }

    for (; row_id < G.outerSize(); row_id++) {
      int k = nb_sub - 1; 
      for (SpMatR::InnerIterator it(G,row_id); it; ++it)
      {
        content[k].push_back(T(row_id - k * (n/nb_sub), it.col(), it.value()));
      }
    }
    for (int k = 1; k < world; k++) {
      int nb_elems = content[k].size();
      MPI_Send(&sizes[k], 1, MPI_INT, k, 0, MPI_COMM_WORLD);
      MPI_Send(&nb_elems, 1, MPI_INT, k, 1, MPI_COMM_WORLD);
      MPI_Send(&content[k][0], nb_elems * sizeof(T), MPI_CHAR, k, 2, MPI_COMM_WORLD);
    }
    SpMatR Gs((sizes[0]), n);
    Gs.setFromTriplets(content[0].begin(), content[0].end());
    // std::cout << "rank " << rank << "\n" << Gs << "\n\n";
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
    //std::cout << "rank " << rank << "\n" << Gs << "\n\n";
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
  int maxi = 250;

  double alpha = 0.85;
  double one_minus_alpha = 1 - alpha;

  int world;
  int rank;
  MPI_Comm_size(MPI_COMM_WORLD, &world);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);

  std::vector<int> sizes;
  std::vector<int> offsets;
  int cum_sum = 0;
  for (int k = 0; k < world; k++) {
    sizes.push_back(n / world);
    offsets.push_back(cum_sum);
    cum_sum += sizes[k];
  }
  sizes[world-1] = n - (world-1) * (n/world);

  SpMatR G = read_and_send_matrix(filename, n);

  auto start = std::chrono::high_resolution_clock::now();
  Eigen::VectorXd p(n);
  Eigen::VectorXd p_partial(n);
  p = Eigen::VectorXd::Ones(n);

  for (int i = 0; i < maxi; i++) {
    p_partial = alpha * (G * p) + one_minus_alpha * p.segment(offsets[rank], sizes[rank]);
    double sum_partial = p_partial.sum();
    double sum_total = 0.0;
    MPI_Allreduce(&sum_partial, &sum_total, 1, MPI_DOUBLE, MPI_SUM, MPI_COMM_WORLD);
    p_partial = p_partial / sum_total;
    MPI_Allgatherv(p_partial.data(), sizes[rank], MPI_DOUBLE, p.data(), sizes.data(), offsets.data(), MPI_DOUBLE, MPI_COMM_WORLD);
  }
  auto stop = std::chrono::high_resolution_clock::now();
  auto duration = std::chrono::duration<float>(stop - start);
  if (rank == 0) {
    std::cout << duration.count() << std::endl;
    std::cout << p[0] << std::endl;
  }
  MPI_Finalize();
  return 0;
}
