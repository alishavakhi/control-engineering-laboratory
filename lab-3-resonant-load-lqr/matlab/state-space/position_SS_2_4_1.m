
C = [1 0 0 0];  


Q = C' * C;      
r = 1e-2;        
R = r;


K = lqr(A, B, Q, R);  


Nr = -1 / (C * inv(A - B*K) * B);


disp('LQR gain K ='); disp(K);
disp('Reference gain N_r ='); disp(Nr);
