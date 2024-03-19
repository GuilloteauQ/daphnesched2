#include <iostream>
#include <Eigen/Dense>
#include <Eigen/Core>

Eigen::MatrixXd calculate_acceleration_matrix(Eigen::MatrixXd position, Eigen::VectorXd mass, double gravity, double softening, int n) {

  auto ones = Eigen::VectorXd::Ones(n);
  auto x = position.col(0);
  auto y = position.col(1);

  auto dx = ones * x.transpose() - x * ones.transpose(); 
  auto dy = ones * y.transpose() - y * ones.transpose(); 

  Eigen::MatrixXd inv_r3(n, n);
  inv_r3 = dx.array().square() + dy.array().square();
  inv_r3 += (softening * softening) * Eigen::MatrixXd::Ones(n, n);
  inv_r3 = inv_r3.array().pow(-1.5);

  Eigen::MatrixXd acceleration(n, 2);
  acceleration.col(0) = gravity * (dx * inv_r3) * mass;
  acceleration.col(1) = gravity * (dy * inv_r3) * mass;

  return acceleration;
}


int main(int argc, char** argv) {
  std::cout << "hello" << std::endl;

  int n = 1000;
  double gravity = 0.00001;
  double step_size = 20.0 / 1000.0;
  double half_step_size = 0.5 * step_size;
  double softening = 0.1;

  auto mat = Eigen::MatrixXd::Random(n, 2);
  auto mat_ones = Eigen::MatrixXd::Ones(n, 2);

  Eigen::MatrixXd position(n, 2);
  Eigen::MatrixXd velocity(n, 2);
  Eigen::MatrixXd acceleration(n, 2);
  Eigen::VectorXd mass(n);

  position = 5.0 * (mat - 5.0 * mat_ones);
  velocity = Eigen::MatrixXd::Zero(n, 2);
  acceleration = Eigen::MatrixXd::Zero(n, 2);
  mass = 500.0 * Eigen::VectorXd::Ones(n);

  position.row(0) = Eigen::MatrixXd::Zero(1, 2);
  velocity.row(0) = Eigen::MatrixXd::Zero(1, 2);
  mass(0) = 10000.0;


  double sum_mass = 0.0;
  Eigen::MatrixXd com_p(1, 2);
  Eigen::MatrixXd com_v(1 ,2);
  com_p = Eigen::MatrixXd::Zero(1, 2);
  com_v = Eigen::MatrixXd::Zero(1, 2);

  for (int i = 0; i < n; i++) {
    sum_mass += mass(i);
    com_p += mass(i) * position.row(i); 
    com_v += mass(i) * velocity.row(i); 
  }
  com_p /= sum_mass;
  com_v /= sum_mass;

  for (int i = 0; i < n; i++) {
    position.row(i) -= com_p;
    velocity.row(i) -= com_v;
  }

  std::cout << position << std::endl;

  for (int iter = 0; iter < 400; iter++) {
    std::cout << iter << std::endl;

    velocity = velocity + acceleration * half_step_size;
    position = position + velocity * step_size;

    acceleration = calculate_acceleration_matrix(position, mass, gravity, softening, n);

    velocity = velocity + acceleration * half_step_size;
  }

  return 0;
}
