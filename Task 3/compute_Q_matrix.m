function Q=compute_Q_matrix(eta_b)
    

    Q=[1 0 -sin(eta_b(2));
       0 cos(eta_b(1)) cos(eta_b(2))*sin(eta_b(1));
       0 -sin(eta_b(1)) cos(eta_b(2))*cos(eta_b(1))];

  
end