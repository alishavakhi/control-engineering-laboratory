Parameters_Resonant_Load;

%Simplified Model
s = tf('s');

%numerator function
mld_tf = mld.Jb*s^2 + mld.Bb*s + mld.k;

%decominator function
a = Jeq*mld.Jb;
b = (Jeq*mld.Bb + mld.Jb*Beq);
c = (Beq*mld.Bb + mld.k*(Jeq + mld.Jb/(gbox.N)^2));
d = mld.k*(Beq+mld.Bb/(gbox.N)^2);
D_tau_pr = a*s^3 + b*s^2 + c*s + d;

simplified_num = (drv.dcgain*mot.Kt)*mld_tf;
simplified_dnom = (gbox.N*s)*(Req*D_tau_pr + mot.Kt*mot.Ke*mld_tf);

simplified_P = simplified_num/simplified_dnom;

%Specification
ts = 0.3;
Mp = 0.3;

delta = log(1/Mp)/sqrt((pi)^2 +(log(1/Mp))^2);
wgc = 3/(delta*ts);
phim = atan(2*delta/sqrt(sqrt(1+4*delta^2) - 2*delta^2));
TL = 1/(10*wgc);

% Response Requirements
dt = delta;
wn = wgc;
phi = atan(sqrt(1 -(dt)^2)/dt);

%PID parameters with Bode

delta_K = 1/abs(evalfr(simplified_P, 1j*wgc));
delta_phi = -pi + phim - angle(evalfr(simplified_P, 1j*wgc));
alpha = 4;

Kp = delta_K*cos(delta_phi);
Td = (tan(delta_phi) + sqrt ((tan(delta_phi))^2 + 4/alpha))/(2*wgc);
Kd = Kp*Td;
Ti = alpha*Td;
Ki = Kp/Ti;

%Anti-windup
Tw = ts/5;
Kw = 1/Tw;
