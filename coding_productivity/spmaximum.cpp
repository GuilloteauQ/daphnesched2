Eigen::VectorXd spmaximum(SpMatR G) {
  int n = G.rows();
  Eigen::VectorXd res = Eigen::VectorXd::Zero(n);
  for (int row_id = 0; row_id < G.outerSize(); row_id++) {
    for (InIterMatR i_(G, row_id); i_; ++i_) {
      auto tmp = G.coeff(row_id, i_.col());
      if (tmp > res.coeff(row_id)) {
        res.coeffRef(row_id) = tmp;
      }
    }
  }
  return res;
}