#include <iostream>
#include <Eigen/Dense>
#include <Eigen/Core>
#include <chrono>
#include "mpi.h"
#include <omp.h>

void add_with_scale(Eigen::MatrixXd A, Eigen::MatrixXd B, double alpha, int rank, int numprocs, int size, MPI_Datatype line_type);

Eigen::MatrixXd compute_distances(Eigen::VectorXd V, int rank, int numprocs, int size) {
  // 1. scatter the data of V.data
  int sub_size = size / numprocs;
  if (rank != 0) {
    Eigen::VectorXd V(size);
  }
  MPI_Bcast(V.data(), size, MPI_DOUBLE, 0, MPI_COMM_WORLD);
  Eigen::VectorXd subV(sub_size);
  MPI_Scatter(V.data(), sub_size, MPI_DOUBLE, subV.data(), sub_size, MPI_DOUBLE, 0, MPI_COMM_WORLD);
  
  // 2. perform ones * V.tranpose()
  Eigen::MatrixXd sub_dv = Eigen::MatrixXd::Zero(size, sub_size);
  sub_dv.rowwise() += subV.transpose();
  sub_dv.colwise() -= V;

  // 3. send back the sub matrix
  Eigen::MatrixXd dv(size, size);
  MPI_Gather(sub_dv.data(), size * sub_size, MPI_DOUBLE, dv.data(), size * sub_size, MPI_DOUBLE, 0, MPI_COMM_WORLD);

  return dv;
}

Eigen::MatrixXd compute_inv_r3(Eigen::MatrixXd X, Eigen::MatrixXd Y, double softening, int rank, int numprocs, int size) {
  int sub_size = (size * size) / numprocs;

  Eigen::VectorXd subX(sub_size);
  Eigen::VectorXd subY(sub_size);
  MPI_Scatter(X.data(), sub_size, MPI_DOUBLE, subX.data(), sub_size, MPI_DOUBLE, 0, MPI_COMM_WORLD);
  MPI_Scatter(Y.data(), sub_size, MPI_DOUBLE, subY.data(), sub_size, MPI_DOUBLE, 0, MPI_COMM_WORLD);
  
  // 2. perform ones * V.tranpose()
  Eigen::MatrixXd sub_dv = Eigen::VectorXd::Zero(sub_size);
  sub_dv = subX.array().square() + subY.array().square();
  sub_dv += softening*softening * Eigen::VectorXd::Ones(sub_size);
  sub_dv = sub_dv.array().pow(-1.5);

  // 3. send back the sub matrix
  Eigen::MatrixXd dv(size, size);
  MPI_Gather(sub_dv.data(), sub_size, MPI_DOUBLE, dv.data(), sub_size, MPI_DOUBLE, 0, MPI_COMM_WORLD);
  return dv;
}

Eigen::MatrixXd compute_acc_component(Eigen::MatrixXd dx, Eigen::MatrixXd inv_r3, Eigen::VectorXd mass, double gravity, int rank, int numprocs, int size) {
  int sub_size = (size * size) / numprocs;

  Eigen::MatrixXd subDX(size,  size / numprocs);
  Eigen::MatrixXd subInv(size, size / numprocs);
  Eigen::VectorXd subMass(size / numprocs);

  MPI_Scatter(dx.data(), size / numprocs, MPI_DOUBLE, subDX.data(), size / numprocs, MPI_DOUBLE, 0, MPI_COMM_WORLD);
  MPI_Scatter(inv_r3.data(), size / numprocs, MPI_DOUBLE, subInv.data(), size / numprocs, MPI_DOUBLE, 0, MPI_COMM_WORLD);
  MPI_Scatter(mass.data(), size / numprocs, MPI_DOUBLE, subMass.data(), size / numprocs, MPI_DOUBLE, 0, MPI_COMM_WORLD);

  // std::cout << "ok scatters\n";
  
  // 2. perform ones * V.tranpose()
  Eigen::VectorXd sub = subInv * subMass;
  Eigen::VectorXd result = Eigen::VectorXd::Zero(size);
  MPI_Reduce(sub.data(), result.data(), size / numprocs, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);
  Eigen::VectorXd result_sub = Eigen::VectorXd::Zero(size / numprocs);
  MPI_Scatter(result.data(), size / numprocs, MPI_DOUBLE, result_sub.data(), size / numprocs, MPI_DOUBLE, 0, MPI_COMM_WORLD);
  // std::cout << "first mat mut\n";

  sub = gravity * subDX * result_sub;
  MPI_Reduce(sub.data(), result.data(), size / numprocs, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);

  return sub;
}

Eigen::MatrixXd calculate_acceleration_matrix(Eigen::MatrixXd position, Eigen::VectorXd mass, double gravity, double softening, int n) {

  auto ones = Eigen::VectorXd::Ones(n);
  auto x = position.col(0);
  auto y = position.col(1);

  int numprocs, rank;
  MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  auto dx = compute_distances(x, rank, numprocs, n);
  auto dy = compute_distances(y, rank, numprocs, n);

  Eigen::MatrixXd inv_r3 = compute_inv_r3(dx, dy, softening, rank, numprocs, n);

  Eigen::MatrixXd acceleration(n, 2);
  acceleration.col(0) = compute_acc_component(dx, inv_r3, mass, gravity, rank, numprocs, n);
  acceleration.col(1) = compute_acc_component(dy, inv_r3, mass, gravity, rank, numprocs, n);

  return acceleration;
}


int main(int argc, char** argv) {
  MPI_Init(&argc, &argv);
  int numprocs, rank;
  MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);


  int n = 1600;
  double gravity = 0.00001;
  double step_size = 20.0 / 1000.0;
  double half_step_size = 0.5 * step_size;
  double softening = 0.1;

  MPI_Datatype line_type;
  MPI_Type_vector(2, 2, 2, MPI_DOUBLE, &line_type);
  MPI_Type_commit(&line_type);

  auto start = std::chrono::high_resolution_clock::now();

  // Init
  Eigen::MatrixXd mat, mat_ones;

  Eigen::MatrixXd position(n, 2);
  Eigen::MatrixXd velocity(n, 2);
  Eigen::MatrixXd acceleration(n, 2);
  Eigen::VectorXd mass(n);

  Eigen::MatrixXd com_p(1, 2);
  Eigen::MatrixXd com_v(1 ,2);

  if (rank == 0) {
    mat = Eigen::MatrixXd::Random(n, 2);
    mat_ones = Eigen::MatrixXd::Ones(n, 2);

    position = 5.0 * (mat - 5.0 * mat_ones);
    velocity = Eigen::MatrixXd::Zero(n, 2);
    acceleration = Eigen::MatrixXd::Zero(n, 2);
    mass = 500.0 * Eigen::VectorXd::Ones(n);

    position.row(0) = Eigen::MatrixXd::Zero(1, 2);
    velocity.row(0) = Eigen::MatrixXd::Zero(1, 2);
    mass(0) = 10000.0;


    double sum_mass = 0.0;
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
  }

  for (int iter = 0; iter < 400; iter++) {
    // velocity = velocity + acceleration * half_step_size;
    add_with_scale(velocity, acceleration, half_step_size, rank, numprocs, n, line_type);
    // position = position + velocity * step_size;
    add_with_scale(position, velocity, step_size, rank, numprocs, n, line_type);

    acceleration = calculate_acceleration_matrix(position, mass, gravity, softening, n);

    // velocity = velocity + acceleration * half_step_size;
    add_with_scale(velocity, acceleration, half_step_size, rank, numprocs, n, line_type);
  }

  auto stop = std::chrono::high_resolution_clock::now();
  auto duration = std::chrono::duration<float>(stop - start);
  std::cout << duration.count() << std::endl;

  MPI_Finalize();

  return 0;
}

// Compute A = A + alpha * B
void add_with_scale(Eigen::MatrixXd A, Eigen::MatrixXd B, double alpha, int rank, int numprocs, int size, MPI_Datatype line_type) {

  int sub_size = size / numprocs;
  // 1. send the size of the sub vectors

  // 2. create the sub vectors
  Eigen::MatrixXd subA(sub_size, 2);
  Eigen::MatrixXd subB(sub_size, 2);

  // 3. send/recv the data for each sub vector
  //MPI_Datatype line_t;
  //MPI_Type_vector(2,// number of block: 2 -> (x, y)
  //                sub_size,// size of the block: 2
  //                size,// stride
  //                MPI_DOUBLE, &line_t);
  //MPI_Type_commit(&line_t);

  MPI_Scatter(A.data(), sub_size, MPI_DOUBLE, subA.data(), sub_size, MPI_DOUBLE, 0, MPI_COMM_WORLD);
  MPI_Scatter(A.data() + size, sub_size, MPI_DOUBLE, subA.data() + sub_size, sub_size, MPI_DOUBLE, 0, MPI_COMM_WORLD);
  //MPI_Scatter(A.data(), 1, line_t, subA.data(), 2*sub_size, MPI_DOUBLE, 0, MPI_COMM_WORLD);
  MPI_Scatter(B.data(), sub_size, MPI_DOUBLE, subB.data(), sub_size, MPI_DOUBLE, 0, MPI_COMM_WORLD);
  MPI_Scatter(B.data() + size, sub_size, MPI_DOUBLE, subB.data() + sub_size, sub_size, MPI_DOUBLE, 0, MPI_COMM_WORLD);

  // 4. do the computations
  subA = subA + subB * alpha;

  // 5. gather the sub vectors
  MPI_Gather(subA.data(), sub_size, MPI_DOUBLE, A.data(), sub_size, MPI_DOUBLE, 0, MPI_COMM_WORLD);
  MPI_Gather(subA.data() + size, sub_size, MPI_DOUBLE, A.data() + sub_size, sub_size, MPI_DOUBLE, 0, MPI_COMM_WORLD);
}
