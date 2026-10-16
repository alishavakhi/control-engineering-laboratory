
C = [1 0 0 0]; 


Ae = [0      -C;
      zeros(4,1)  A];

Be = [0;
      B];


Qe = diag([
    10,             
    1 / (0.3*pi/180)^2,  
    1 / (5*pi/180)^2,     
    1,              
    1               
]);

r = 0.01;                     
Re = r;


Ke = lqr(Ae, Be, Qe, Re);     


KI = Ke(1);        
K  = Ke(2:end);   


Nr = -1 / (C * inv(A - B*K) * B);


disp('Integral gain KI ='); disp(KI);
disp('State feedback gain K ='); disp(K);
disp('Reference gain N_r ='); disp(Nr);
