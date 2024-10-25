#include <iostream>
#include <Eigen/SparseCore>
#include <Eigen/Dense>
#include <Eigen/Sparse>
#include <Eigen/Core>
#include <unsupported/Eigen/SparseExtra>
#include <chrono>
#include <iomanip>

typedef Eigen::SparseMatrix<double, Eigen::ColMajor> SpMatC;
typedef Eigen::SparseMatrix<double, Eigen::RowMajor> SpMatR;

int main(int argc, char** argv) {
  if (argc != 3) {
    std::cout << "Usage: bin mat.mtx size" << std::endl;
    return 1;
  }
  std::string filename = argv[1];

  int n = atoi(argv[2]);
  int maxi = 200;
  auto start_reading = std::chrono::high_resolution_clock::now();

  SpMatR G(n, n); 
  if (!loadMarket(G, filename)) {
    std::cout << "could  not load mtx file" << std::endl;
    return 1;
  }
  auto start_compute = std::chrono::high_resolution_clock::now();

  Eigen::VectorXd x = Eigen::VectorXd::Zero(n);
  x(0) = 1.0;
  Eigen::VectorXd ones = Eigen::VectorXd::Ones(n);

  for (int i = 0; i < maxi; i++) {
    x = ones.array().min((x + G * x).array());
  }
  auto stop = std::chrono::high_resolution_clock::now();
  auto duration_compute = std::chrono::duration<float>(stop - start_compute);
  auto duration_reading = std::chrono::duration<float>(stop - start_reading);
  std::cout << duration_reading.count() << "," << duration_compute.count() << "," << std::setprecision (16) << x.sum() << std::endl;
  return 0;
}
