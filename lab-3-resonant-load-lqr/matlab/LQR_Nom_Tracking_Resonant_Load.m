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

% Allowable Region for Response Requirements
sigma = -3/ts;

% SLR
sysG = ss(A, B, C, D);
sysGp = ss(-A, -B, -C, D);

% gain
r = 1.7e-2;
roots = zero(1 + 1/r*sysGp*sysG);


% plots
% plot(real(roots),imag(roots),"o")
% axis equal
% grid on
% xlabel("Re")
% ylabel("Im")
% hold on
% plot([0, -100], [0, 100*tan(phi)]);
% plot([0, -100], [0, 100*tan(-phi)]);
% line([sigma, sigma], [-100, 100]);

%FeedBack Matrix
K_Nom_LQR = lqr(sysG, C'*C, r);

% Calculation for Nominal Tracking
N_mat = [A, B;
          C, 0];

N_res = linsolve(N_mat, [0, 0, 0, 0, 1].');

Nx = N_res(1:4);
Nu = N_res(5);



