%Calculation for Nominal Tracing
N_mat = [A, B;
          C, 0];

N_res = linsolve(N_mat, [0, 0, 1].');

Nx = N_res(1:2);
Nu = N_res(3);


p_nom = [-dt*wn + 1j*wn*sqrt(1-dt^2), -dt*wn - 1j*wn*sqrt(1-dt^2)];
K_nom = place(A,B,p_nom)



