#include <iostream>
#include <Eigen/SparseCore>
#include <Eigen/Dense>
#include <Eigen/Sparse>
#include <Eigen/Core>
#include <unsupported/Eigen/SparseExtra>
#include <chrono>
#include <mpi.h>

typedef Eigen::SparseMatrix<double, Eigen::RowMajor> SpMatR;

SpMatR read_and_send_matrix(std::string filename, int n) {
  int world;
  int rank;
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
  }
}

int main(int argc, char** argv) {
  if (argc != 3) {
    std::cout << "Usage: bin mat.mtx size" << std::endl;
    return 1;
  }
  std::string filename = argv[1];

  int n = atoi(argv[2]);
  int maxi = 250;

  double alpha = 0.85;
  double one_minus_alpha = 1 - alpha;

  SpMatR G(n, n); 
  if (!loadMarket(G, filename))
    std::cout << "could  not load mtx file" << std::endl;

  auto start = std::chrono::high_resolution_clock::now();
  Eigen::VectorXd p(n);
  p = Eigen::VectorXd::Ones(n);

  for (int i = 0; i < maxi; i++) {
    p = (G * p) * alpha + p * one_minus_alpha;
    p = p / p.sum();
  }
  auto stop = std::chrono::high_resolution_clock::now();
  auto duration = std::chrono::duration<float>(stop - start);
  std::cout << duration.count() << std::endl;
  std::cout << p[0] << std::endl;
  return 0;
}
