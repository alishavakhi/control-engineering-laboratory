%Calculation for Nominal Tracing
N_mat = [A, B;
          C, 0];

N_res = linsolve(N_mat, [0, 0, 1].');

Nx = N_res(1:2);
Nu = N_res(3);


p_nom = [-dt*wn + 1j*wn*sqrt(1-dt^2), -dt*wn - 1j*wn*sqrt(1-dt^2)];
K_nom = place(A,B,p_nom);

A_22 = A(2,2);
A_12 = A(1,2);

L_ro = place(A_22,A_12, -5*wn*sqrt(1-dt^2));

A_0 = A_22 - L_ro;
B_0 = [B(1) A_0*L_ro];
C_0 = [0; 1];
D_0 = [0 1;
       0 L_ro];





