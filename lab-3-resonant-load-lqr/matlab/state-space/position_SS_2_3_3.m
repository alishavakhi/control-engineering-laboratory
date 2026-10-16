
Ae = [0         C;
      zeros(4,1) A];

Be = [0;
      B];


Mp = 0.10;         
ts = 0.50;         


delta = log(1/Mp) / sqrt(pi^2 + log(1/Mp)^2);
omega_n = 3 / (delta * ts);


lambda5 = -omega_n;
lambda1 = -20.0000 - 2.1863i;
lambda2 = -20.0000 + 2.1863i;
lambda3 = -45.0000 - 2.1863i;
lambda4 = -45.0000 + 2.1863i;


desired_poles = [lambda1; lambda2; lambda3; lambda4; lambda5];

Ke = place(Ae, Be, desired_poles);   
Ke = real(Ke);

KI = Ke(1);           
K  = Ke(2:end);       


disp('Integral gain KI ='); disp(KI);
disp('State feedback gain K ='); disp(K);
Nr = -1 / (C * inv(A - B*K) * B);
disp('Reference gain N_r ='); disp(Nr);
