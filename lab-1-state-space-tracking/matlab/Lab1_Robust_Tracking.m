%Calculation for Robust Tracking with Integral Action
A_e = [0, C;
       [0;0], A;];
B_e = [0; B];
C_e = [0, C];


sigma = -dt*wn;
wd = wn*sqrt(1-dt^2);

p_rob_1 = [sigma + 1j*wd, sigma - 1j*wd, sigma];
p_rob_2 = [sigma, sigma, sigma];
p_rob_3 = [2*sigma + 1j*wd, 2*sigma - 1j*wd, 2*sigma];
p_rob_4 = [2*sigma + 1j*wd, 2*sigma - 1j*wd, 3*sigma];

Ke = acker(A_e,B_e,p_rob_2);
K_rob = Ke(2:3);
Ki_rob = Ke(1);

