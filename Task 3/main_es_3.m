clc
clear 
close all


load("flight-data.mat");


%% Parameters
m = 1.5;                                      
I_b = diag([1.2416 1.2416 2*1.2416]);         
g = 9.81;
e3 = [0 0 1]';

Ts = 0.001;                                   
T = attitude.time;
outputFolder = fullfile(pwd, 'figures');
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end





%% MAIN LOOP OVER DIFFERENT ESTIMATOR ORDERS
orders = [1, 3, 5, 9];

for idx = 1:length(orders)
    r = orders(idx);
    fprintf('Running estimator for r = %d...\n', r);

    % Reset memory
    ext_wrench = zeros(6, length(T));
    q = zeros(6, length(T));
    gamma = zeros(6, length(T), r);

    %% Estimator gains via Butterworth filter
   % k_0=10;
   % c_0=10;
   % s = tf('s');
   % G = k_0^r / (s + c_0)^r;
   % c = cell2mat(G.Denominator);
   % c = c(2:end);
    wc = 1;  % Cut-off frequency [rad/s]
    [b_but, a_but] = butter(r, wc, "low", 's');   % Butterworth filter
    c = a_but(2:end);                  % remove leading a0 = 1

    % Compute K_i from denominator
    K = zeros(1, r);
    P = 1;
    for i = 1:r
        K(i) = c(i) / P;
        P = P * K(i);
    end
    K = flip(K);

    %% Estimator execution
    for k = 1:length(T)-1
        eta_b      = attitude.signals.values(k,:);
        eta_b_next = attitude.signals.values(k+1,:);
        eta_dot_b  = attitude_vel.signals.values(k,:)';
        eta_dot_b_next = attitude_vel.signals.values(k+1,:)';
        lin_vel    = linear_vel.signals.values(k+1,:)';

        M = [m*eye(3), zeros(3,3); 
             zeros(3,3), compute_Q_matrix(eta_b_next)' * I_b * compute_Q_matrix(eta_b_next)];

        q(:,k+1) = M * [lin_vel; eta_dot_b_next];

        C  = compute_matrix_C(eta_b, eta_dot_b, I_b);
        Q  = compute_Q_matrix(eta_b);
        Rb = compute_R(eta_b);

        thrust_k = thrust.signals.values(k);
        tau_k    = tau.signals.values(k,:)';

        input_term = [m*g*e3 - thrust_k*Rb*e3;
                      C'*eta_dot_b + Q'*tau_k];

        delta_q = q(:,k+1) - q(:,k);
        gamma(:,k+1,1) = gamma(:,k,1) + K(1)*(delta_q - Ts*input_term - Ts*ext_wrench(:,k));

        for i = 2:r
            gamma(:,k+1,i) = gamma(:,k,i) + Ts*K(i)*(-ext_wrench(:,k) + gamma(:,k,i-1));
        end

        ext_wrench(:,k+1) = gamma(:,k+1,r);
    end


    %%stima massa
    Rb_end = compute_R(attitude.signals.values(end,:));
    ub = thrust.signals.values(end) * Rb_end * e3;
    
    m_tilde1 = -ext_wrench(3,end) / g;
    real_m1 = m - m_tilde1;
    
    % m_tilde2 = (m*g - ub(3)) / g;
    % real_m2 = m - m_tilde2;


%% Plotting
fx_ref = 1 * ones(1,length(T));
fy_ref = 1 * ones(1,length(T));
tauz_ref = -0.4 * ones(1,length(T));

fig = figure('Name', sprintf('Wrench estimation for r=%d', r), ...
         'NumberTitle', 'off', ...
         'Position', [200, 200, 800, 700]);

tiledlayout(fig, 3, 2, 'TileSpacing','compact', 'Padding','compact');

nexttile
plot(T, ext_wrench(1,:), 'LineWidth', 1.5); hold on
plot(T, fx_ref, '--k', 'LineWidth', 1.2)
grid on
title('$\hat{f}_x$', 'Interpreter', 'latex', 'FontSize', 16)
ylabel('[N]', 'Interpreter', 'latex')
xlabel('Time [s]', 'Interpreter', 'latex')
legend({'$\hat{f}_x$', '$f_x$ ref'}, 'Interpreter', 'latex', 'FontSize', 16, 'Location', 'best')

nexttile
plot(T, ext_wrench(4,:), 'LineWidth', 1.5)
grid on
title('$\hat{\tau}_x$', 'Interpreter', 'latex','FontSize', 16)
ylabel('[Nm]', 'Interpreter', 'latex')
xlabel('Time [s]', 'Interpreter', 'latex')

nexttile
plot(T, ext_wrench(2,:), 'LineWidth', 1.5); hold on
plot(T, fy_ref, '--k', 'LineWidth', 1.2)
grid on
title('$\hat{f}_y$', 'Interpreter', 'latex','FontSize', 16)
ylabel('[N]', 'Interpreter', 'latex')
xlabel('Time [s]', 'Interpreter', 'latex')
legend({'$\hat{f}_y$', '$f_y$ ref'}, 'Interpreter', 'latex', 'FontSize', 16, 'Location', 'best')

nexttile
plot(T, ext_wrench(5,:), 'LineWidth', 1.5)
grid on
title('$\hat{\tau}_y$', 'Interpreter', 'latex','FontSize', 16)
ylabel('[Nm]', 'Interpreter', 'latex')
xlabel('Time [s]', 'Interpreter', 'latex')

nexttile
plot(T, ext_wrench(3,:), 'LineWidth', 1.5)
grid on
title('$\hat{f}_z$', 'Interpreter', 'latex','FontSize', 16)
ylabel('[N]', 'Interpreter', 'latex')
xlabel('Time [s]', 'Interpreter', 'latex')

nexttile
plot(T, ext_wrench(6,:), 'LineWidth', 1.5); hold on
plot(T, tauz_ref, '--k', 'LineWidth', 1.2)
grid on
title('$\hat{\tau}_z$', 'Interpreter', 'latex','FontSize', 16)
ylabel('[Nm]', 'Interpreter', 'latex')
xlabel('Time [s]', 'Interpreter', 'latex')
legend({'$\hat{\tau}_z$', '$\tau_z$ ref'}, 'Interpreter', 'latex', 'FontSize', 16, 'Location', 'best')

% Save the figure.
fname = sprintf('wrench_estimation_r%d', r);
print(gcf, fullfile(outputFolder, fname), '-depsc2', '-r600');
end

