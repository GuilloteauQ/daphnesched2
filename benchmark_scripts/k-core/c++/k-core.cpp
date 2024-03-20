#include <iostream>
#include <Eigen/SparseCore>
#include <Eigen/Dense>
#include <Eigen/Sparse>
#include <Eigen/Core>
#include <unsupported/Eigen/SparseExtra>


typedef Eigen::SparseMatrix<int, Eigen::RowMajor> SpMatR;

int main(int argc, char** argv) {
  std::string filename = "../python/amazon0601/amazon0601.mtx";
  //std::string filename = "../python/amazon0601/small.mtx";

  int n = 403394; // TODO: manage this
  // int n = 8; // TODO: manage this

  SpMatR G(n, n); 
  if (!loadMarket(G, filename))
    std::cout << "could  not load mtx file" << std::endl;

  Eigen::VectorXi c(n);
  Eigen::VectorXi x(n);
  Eigen::VectorXi prev(n);

  c = Eigen::VectorXi::Ones(n);
  x = Eigen::VectorXi::Zero(n);
  int diff = 1;
  int k = 9;

  while (diff != 0) {
    prev = c;
    x = G * c;
    c = (x.array() >= k).cast<int>().matrix();
    diff = (c.array() != prev.array()).count();
  }
  // std::cout << c << std::endl;
  return 0;
}
