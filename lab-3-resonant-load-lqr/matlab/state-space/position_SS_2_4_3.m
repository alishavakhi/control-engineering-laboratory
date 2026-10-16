
C = [1 0 0 0];  


theta_h_max = 0.3 * 50 * pi / 180;     
theta_d_max = pi / 36;                
u_max = 10;                            


Q = diag([
    9 / (theta_h_max^2);    
    0.3 / (theta_d_max^2);    
    0;                      
    0                       
])

R = 10 / (u_max^2)         


K = lqr(A, B, Q, R);        


Nr = -1 / (C * inv(A - B*K) * B);


disp('LQR gain K ='); disp(K);
disp('Reference gain N_r ='); disp(Nr);
