Theta_d_exp = Theta_d.signals.values(5251:end);
Theta_d_time = Theta_d.time(5251:end) - 5.25;
peaks = [12.5 11.83 10.66 10.1 9.03 8.48 7.53 6.89 5.95 5.5 4.49 4.03 2.93 2.495 1.465 1.14]; 
peak_times = [0 0.156 0.28 0.415 0.55 0.68 0.815 0.945 1.074 1.206 1.34 1.465 1.59 1.714 1.846 1.974];

Y = log(peaks);
Phi_elem = 0:length(peaks)-1;
Phi_elem =  - Phi_elem';
Phi=  [Phi_elem , ones(16,1)]

