
Theta_d_exp = abs(Theta_d.signals.values(5251:end));
Theta_d_time = Theta_d.time(5251:end) - 5.25;
peaks = [12.5 11.83 10.66 10.1 9.03 8.48 7.53 6.89 5.95 5.5 4.49 4.03 2.93 2.495 1.465 1.14]; 
peak_times = [0 0.156 0.28 0.415 0.55 0.68 0.815 0.945 1.074 1.206 1.34 1.465 1.59 1.714 1.846 1.974];

Y = log(peaks);
Y = Y';
Phi_elem = 0:length(peaks)-1;
Phi_elem =  - Phi_elem';
Phi=  [Phi_elem , ones(16,1)];

A = Phi' * Phi;
b = Phi' * Y;

ThLs = lsqr(A,b);
delta_hat = ThLs(1) / sqrt(pi^2 + ThLs(1)^2);

for i = 1:length(peak_times)
    if i == 16 
        w_hat_mat(i) = pi / (2.118 - peak_times(i));
        break;
    end
w_hat_mat(i) = pi / (peak_times(i+1) - peak_times(i));
end

w_hat = mean(w_hat_mat);

wn_hat = w_hat / sqrt(1-delta_hat^2);

Bb_hat = mld.Jb *(2*delta_hat*wn_hat);
k_hat = mld.Jb * wn_hat^2;