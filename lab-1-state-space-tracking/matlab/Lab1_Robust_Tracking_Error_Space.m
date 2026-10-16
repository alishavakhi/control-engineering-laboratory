%Calculation for Robust Tracking with IMP
Tr = [0.15, 0.25, 0.5, 1];
w0 = (2*pi) /Tr(3);

A_z_star = [0, 1, 0;
           0, 0, 1;
           0 -w0^2, 0;];
C_z_star = [1, 0, 0];

A_z = [A_z_star, [0, 0; 0,0; C];
       [0, 0, 0;
        0, 0, 0;], A];
B_z = [0; 0; 0; B];


wn_adj = 40;


p_1 = wn_adj*exp(1j*(-pi+pi/4));
p_2 = wn_adj*exp(1j*(-pi-pi/4));
p_3 = wn_adj*exp(1j*(-pi+pi/6));
p_4 = wn_adj*exp(1j*(-pi-pi/6));
p_5 = -wn_adj;

p_err_sp = [p_1, p_2, p_3,p_4, p_5];
K_err_sp = acker(A_z,B_z,p_err_sp);

alpha = [1 0 w0^2 0];
km = flip(K_err_sp(1:3));
k_ksi = K_err_sp(4:end);

