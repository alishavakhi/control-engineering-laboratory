Parameters_Resonant_Load;
PID_Parameters;

%System Matrices
A = [0, 0, 1, 0;
     0, 0, 0, 1;
     0, mld.k/(gbox.N^2*Jeq), -1/Jeq*(Beq + mot.Ke*mot.Kt/Req), 0; 
     0, -mld.k/mld.Jb - mld.k/(gbox.N^2*Jeq), -mld.Bb/mld.Jb+1/Jeq*(Beq + mot.Ke*mot.Kt/Req) , -mld.Bb/mld.Jb;];

B = [0, 0, mot.Kt*drv.dcgain/(gbox.N*Jeq*Req), -mot.Kt*drv.dcgain/(gbox.N*Jeq*Req)].';
C = [1, 0, 0, 0];
D = 0;

% Spcifications
th_h_max = 0.3 * 50 * pi / 180;     
th_d_max = pi / 36;                
u_max = 10;                            

% Weight Calculations
Q = diag([
    9 / (th_h_max^2);    
    0.3 / (th_d_max^2);    
    0;                      
    0                       
]);

r = 10 / (u_max^2);         


%FeedBack Matrix
K_Nom_LQR_Br = lqr(A, B, Q, r); 


% Calculation for Nominal Tracking
N_mat = [A, B;
          C, 0];

N_res = linsolve(N_mat, [0, 0, 0, 0, 1].');

Nx = N_res(1:4);
Nu = N_res(5);