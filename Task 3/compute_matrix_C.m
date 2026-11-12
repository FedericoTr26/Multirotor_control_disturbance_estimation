function C = compute_matrix_C(eta_b, eta_dot_b, I_b)
    
    Q = compute_Q_matrix(eta_b);
    Q_dot = compute_Q_dot_mat(eta_b, eta_dot_b);
    S = skew(Q * eta_dot_b(:));

    % S = skew(Q*eta_dot_b');
    C = Q'*S*I_b*Q+Q'*I_b*Q_dot;

end