#include <iostream>
#include <Eigen/SparseCore>
#include <Eigen/Dense>
#include <Eigen/Sparse>
#include <Eigen/Core>
#include <unsupported/Eigen/SparseExtra>

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
  std::string filename = "amazon0601/amazon0601.mtx";

  int n = 403394; // TODO: manage this

  SpMatR G(n, n); 
  if (!loadMarket(G, filename))
    std::cout << "could  not load mtx file" << std::endl;

  Eigen::VectorXi c(n);
  for (int i = 0; i < n; i++) {
    c(i) = i + 1;
  }

  Eigen::VectorXi x(n);
  G = G.transpose();

  for (int iter = 0; iter < 40; iter++) {
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
  return 0;
}
