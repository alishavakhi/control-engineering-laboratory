
Mp = 0.30;        
ts = 0.85;       


delta = log(1/Mp) / sqrt(pi^2 + (log(1/Mp))^2);


omega_n = 3 / (delta * ts);


lambda1 = -delta*omega_n + 1i*omega_n*sqrt(1 - delta^2);
lambda2 = -delta*omega_n - 1i*omega_n*sqrt(1 - delta^2);


phi = atan(sqrt(1 - delta^2)/delta);
lambda3 = omega_n * exp(1i*(-pi + phi/2));
lambda4 = omega_n * exp(1i*(-pi - phi/2));


desired_poles = [lambda1; lambda2; lambda3; lambda4];


K = place(A, B, desired_poles);
K = real(K);

disp('State-feedback gain K ='); disp(K)
disp('Desired poles ='); disp(desired_poles)

C = [1 0 0 0];


N_bar = -1 / (C * inv(A - B*K) * B);
Nr= real(N_bar);

disp('Nr ='); disp(Nr);
K2=[-1.0743    1.0851    0.0140   -0.0107]