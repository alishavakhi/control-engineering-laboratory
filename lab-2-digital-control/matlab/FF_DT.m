HPs_nom = [wc2 0];
HPs_dnom = [1 2*delta_i*wc wc2];

HPs = tf(HPs_nom, HPs_dnom);

HPz = c2d_euler(HPs,T1,'backward');

[HPz_nom HPz_dnom] = tfdata(HPz, 'v'); 


