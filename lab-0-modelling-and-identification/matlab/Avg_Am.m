% j = 1;
% Sum = 0;
% 
% Am_filtered = Am.signals.values;
% Am_filtered = Am_filtered(2:end);
% Am_filtered(1:10:end) = [];
% Am_filtered = Am_filtered*1000*rpm2rads;
% for i=1:length(Am_filtered)
% 
%     if mod(i,9) == 0
%         Avgd_Am(j) = Sum /9;
%         j = j + 1;
%         Sum = 0;
%     end
% 
%     Sum = Sum + Am_filtered(i);
% 
% 
% end
% Tf = 7.9953e-07*Wm.signals.values*1000*rpm2rads + 0.008*SGR.signals.values;
% Ti = Tm.signals.values - Tf;
% Ti_filtered = Ti(2:end);
% Ti_filtered(1:10:end) = [];
% % 
% % Tm_filtered = Tm.signals.values(2:end);
% % Tm_filtered(1:10:end) = [];
% 
% j = 1;
% Sum = 0;
% for i=1:length(Ti_filtered)
% 
%     if mod(i,9) == 0
%         Avgd_Ti(j) = Sum /9;
%         j = j + 1;
%         Sum = 0;
%     end
% 
%     Sum = Sum + Ti_filtered(i);
% 
% end

for i=1:length(Avgd_Ti)/2
    Jeq_hat(i) = (Avgd_Ti(i+1) - Avgd_Ti(i)) /  (Avgd_Am(i+1) - Avgd_Am(i))
end

