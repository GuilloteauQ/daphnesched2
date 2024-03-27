#include <iostream>
#include <Eigen/SparseCore>
#include <Eigen/Dense>
#include <Eigen/Sparse>
#include <Eigen/Core>
#include <unsupported/Eigen/SparseExtra>
#include <chrono>

#define MAX(x, y) ((x) < (y)) ? (y) : (x)

typedef Eigen::SparseMatrix<int, Eigen::ColMajor> SpMatC;
typedef Eigen::SparseMatrix<int, Eigen::RowMajor> SpMatR;
typedef Eigen::SparseVector<int, Eigen::ColMajor> SpVecC;
typedef Eigen::SparseVector<int, Eigen::RowMajor> SpVecR;
typedef Eigen::Array<int, 1, Eigen::Dynamic> Vec;

typedef SpMatC::InnerIterator InIterVec;
typedef Eigen::MappedSparseMatrix<int> MSpMat;
// typedef MSpMat::InnerIterator InIterMat;
typedef SpMatC::InnerIterator InIterMatC;
typedef SpMatR::InnerIterator InIterMatR;

int main(int argc, char** argv) {
  if (argc != 3) {
    std::cout << "Usage: bin mat.mtx size" << std::endl;
    return 1;
  }
  std::string filename = argv[1];

  int n = atoi(argv[2]);

  SpMatR G(n, n); 
  if (!loadMarket(G, filename))
    std::cout << "could  not load mtx file" << std::endl;

  auto start = std::chrono::high_resolution_clock::now();

  Eigen::VectorXi c(n);
  for (int i = 0; i < n; i++) {
    c(i) = i + 1;
  }

  Eigen::VectorXi x(n);
  G = G.transpose();

  for (int iter = 0; iter < 100; iter++) {
#pragma omp parallel for
    for (int row_id = 0; row_id < G.outerSize(); row_id++) {
      double current_max = c.coeffRef(row_id);
      for (InIterMatR i_(G, row_id); i_; ++i_) {
        double tmp = c.coeffRef(i_.col());
        if (tmp > current_max) {
          current_max = tmp;
        }
      }
      x.coeffRef(row_id) = current_max;
    }
    double sum_ = 0.0;
    for (int j = 0; j < n; j++) {
      c.coeffRef(j) = MAX(c.coeffRef(j), x.coeffRef(j));
      sum_ += c.coeffRef(j);
    }
    // std::cout << iter << ": " << sum_ << std::endl;
  }
  // std::cout << Eigen::nbThreads( ) << std::endl;
  auto stop = std::chrono::high_resolution_clock::now();
  // auto duration = std::chrono::duration_cast<std::chrono::seconds>(stop - start);
  auto duration = std::chrono::duration<float>(stop - start);
  std::cout << duration.count() << std::endl;
  return 0;
}
