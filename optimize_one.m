clc; clear; close all;
addpath('functions', 'data');

opts_ode = odeset('RelTol',1e-7,'AbsTol',1e-9);
opts_opt = optimoptions('lsqnonlin','Display','iter','FunctionTolerance',1e-10,'StepTolerance',1e-10,'OptimalityTolerance',1e-10);
a0 = 0.009181836373270;
a = lsqnonlin(@(a) R(a), a0, 0.006, 0.012, opts_opt);

fprintf('===============================\n');
fprintf('Optimized a:     %.10f', a);

function r = R(a)
u0=0; uf=122000;
[P0_atm, Q, pEnd_atm, ro, ~, tempGasStart, ~] = getExpDataFunc(5);
p0 = atm2pa_func(P0_atm); % convert to Pa
options = odeset('RelTol', 1e-6, 'AbsTol', 1e-9, 'MaxStep', 100);
Qsec = day2sec_func(Q); % from m3/day to m3/s
[u,y]=ode45(@(u,p) Rozrax_Cp_Func(u,p, Qsec, ro, tempGasStart, a),[u0 uf], p0, options);
% Convert pressure from Pa to atm (1 atm = 101325 Pa)
p_atm = y / 101325;

% Calculate final pressure and error analysis
p_final_calculated = p_atm(end);  % Last calculated pressure value
p_final_expected = pEnd_atm;      % Expected final pressure

% Calculate errors
absolute_error = p_final_calculated - p_final_expected;
relative_error_percent = (absolute_error / (P0_atm - p_final_expected)) * 100;

r = 0 - relative_error_percent;

end