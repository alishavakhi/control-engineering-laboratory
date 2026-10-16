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

%Matrices for Robust Tracking with Integral Action
A_e = [0, C;
       [0;0;0;0], A;];
B_e = [0; B];
C_e = [0, C];


% Calculation for Nominal Tracking
N_mat = [A, B;
         C, 0];

N_res = linsolve(N_mat, [0, 0, 0, 0, 1].');

Nx = N_res(1:4);
Nu = N_res(5);

%  Desired eigenvalues
p1 = wn*exp(1j*(-pi+phi));
p2 = wn*exp(1j*(-pi-phi));
p3 = wn*exp(1j*(-pi+phi/2));
p4 = wn*exp(1j*(-pi-phi/2));
p5 = -wn;

p_rob = [p1, p2, p3, p4, p5];
Ke = acker(A_e,B_e,p_rob);
K_rob = Ke(2:5);
Ki_rob_calc = Ke(1);
Ki_rob = 100;


