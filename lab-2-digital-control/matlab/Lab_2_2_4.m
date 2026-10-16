
Phi_e = [1, H;           
         zeros(2,1), Phi];
Gamma_e = [0;
           Gamma];       

z3 = 0.95;
Ke = place(Phi_e, Gamma_e, [z1, z2, z3]);
K_I = Ke(1);        
K1   = Ke(2:end);    



disp('--- 2.2.4 Integral Control ---');
disp(['K_I = ' num2str(K_I)]);
disp(['K   = [' num2str(K) ']']);
disp(['Nr  = ' num2str(Nr)]);
