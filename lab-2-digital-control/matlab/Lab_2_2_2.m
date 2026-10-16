
A = [0, 1;
     0, -1/Tm_calc];
B = [0;
     Km_calc / (gbox.N * Tm_calc)];
C = [1, 0];
D = 0;
sys_c = ss(A, B, C, D);


Ts = 0.001; 


sys_d = c2d(sys_c, Ts, 'zoh');
[Phi, Gamma, H, J] = ssdata(sys_d);


Mp = 0.25;       
ts = 0.12;       

zeta = -log(Mp)/sqrt(pi^2 + log(Mp)^2);
wn = 3 / (zeta * ts);


s1 = (-zeta * wn + 1j * wn * sqrt(1 - zeta^2));
% s2 = -zeta * wn - 1j * wn * sqrt(1 - zeta^2);
s2 = conj(s1);


s_o = 5 * real(s1);


%%z1 = exp(s1 * Ts);
%%z2 = exp(s2 * Ts);
z1=0.75+0.0552i
z2=conj(z1)
z_o = exp(s_o * Ts);


K = place(Phi, Gamma, [z1, z2]);


Phi11 = Phi(1,1); Phi12 = Phi(1,2);
Phi21 = Phi(2,1); Phi22 = Phi(2,2);
Gamma1 = Gamma(1); Gamma2 = Gamma(2);


L = (Phi22 - z_o) / Phi12;


Phi_o = Phi22 - L * Phi12;
Gamma_o = [Gamma2 - L * Gamma1, ...
           (Phi22 - L * Phi12) * L + Phi21 - L * Phi11];
H_o = [0; 1];
J_o = [0, 1; 0, L];


Aeq = [Phi - eye(2), Gamma;
       H,           0];
beq = [0; 0; 1];
sol = Aeq \ beq;
Nx = sol(1:2);
Nu = sol(3);
Nr = Nu + K * Nx;

disp('--- Section 2.2.2 Complete Design ---');
disp('Sampling time Ts = 10 ms');
disp('Poles in s-domain:'); disp([s1, s2]);
disp('Mapped poles in z-domain:'); disp([z1, z2]);
disp('Observer pole in z:'); disp(z_o);
disp('K = '); disp(K);
disp('L = '); disp(L);
disp('Nx = '); disp(Nx.');
disp(['Nu = ', num2str(Nu)]);
disp(['Nr = ', num2str(Nr)]);
disp('Observer Matrices:');
disp('Phi_o = '); disp(Phi_o);
disp('Gamma_o = '); disp(Gamma_o);
disp('H_o = '); disp(H_o);
disp('J_o = '); disp(J_o);
