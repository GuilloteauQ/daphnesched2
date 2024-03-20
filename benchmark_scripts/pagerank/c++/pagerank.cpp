#include <iostream>
#include <Eigen/SparseCore>
#include <Eigen/Dense>
#include <Eigen/Sparse>
#include <Eigen/Core>
#include <unsupported/Eigen/SparseExtra>


typedef Eigen::SparseMatrix<double, Eigen::RowMajor> SpMatR;

int main(int argc, char** argv) {
  // std::string filename = "../../k-core/python/amazon0601/amazon0601.mtx";
  std::string filename = "../../k-core/python/amazon0601/small.mtx";

  // int n = 403394; // TODO: manage this
  int n = 8; // TODO: manage this
  //
  int maxi = 260;

  double alpha = 0.85;
  double one_minus_alpha = 1 - alpha;

  SpMatR G(n, n); 
  if (!loadMarket(G, filename))
    std::cout << "could  not load mtx file" << std::endl;

  Eigen::VectorXd p(n);
  p = Eigen::VectorXd::Ones(n);

  for (int i = 0; i < maxi; i++) {
    p = (G * p) * alpha + p * one_minus_alpha;
    p = p / p.sum();
  }
  // std::cout << p << std::endl;
  // std::cout << G << std::endl;
  return 0;
}
