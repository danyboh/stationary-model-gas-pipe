function [p_final_calculated, relative_error_percent, absolute_error]=calcBaseWithValuesFunc(lyam, P0_atm, Q, pEnd_atm) % p - Pa
u0=0; uf=122000;
p0 = atm2pa_func(P0_atm); % convert to Pa
T0 = 273.15+40; 
y0=[p0 T0];
options = odeset('RelTol', 1e-6, 'AbsTol', 1e-9, 'MaxStep', 100);
Qsec = day2sec_func(Q); % from m3/day to m3/s
%best for point 5 = 0.0091789810
[u,y]=ode45(@(u,y) SystRivn_v_2_Danyl_Func(u,y, Qsec,lyam),[u0 uf], y0, options);
% Convert pressure from Pa to atm (1 atm = 101325 Pa)
p_atm = y(:,1) / 101325;

% Calculate final pressure and error analysis
p_final_calculated = p_atm(end);  % Last calculated pressure value
p_final_expected = pEnd_atm;      % Expected final pressure

% Calculate errors
absolute_error = p_final_calculated - p_final_expected;
relative_error_percent = (absolute_error / (P0_atm - p_final_expected)) * 100;
rp = relative_error_percent;



