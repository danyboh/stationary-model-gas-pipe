clc; clear; close all;
addpath('functions', 'data');

opts_ode = odeset('RelTol',1e-7,'AbsTol',1e-9);
opts_opt = optimoptions('lsqnonlin','Display','iter','FunctionTolerance',1e-10,'StepTolerance',1e-10,'OptimalityTolerance',1e-10);
a = lsqnonlin(@(a) R(a), 3.5, 3, 4, opts_opt);

fprintf('===============================\n');
fprintf('Optimized a:     %.10f', a);

function r = R(a)
u0=0; uf=122000;
pEnd_atm = 48.5;
options = odeset('RelTol', 1e-6, 'AbsTol', 1e-9, 'MaxStep', 100);
Q1=day2sec_func(3506); 
P0_atm = 66.6; 
p1 = P0_atm*101325;   % Pa
T1 = 273.15+40;
y0=[p1 T1];
[u,y]=ode45(@(u,p) SystRivn_v_2_Danyl_Func(u,p, Q1, a, 3.57254168),[u0 uf], y0, options);
% Convert pressure from Pa to atm (1 atm = 101325 Pa)
p_atm = y(:,1) / 101325;

% Calculate final pressure and error analysis
p_final_calculated = p_atm(end);  % Last calculated pressure value
p_final_expected = pEnd_atm;      % Expected final pressure

% Calculate errors
absolute_error = p_final_calculated - p_final_expected;
relative_error_percent = (absolute_error / (p_final_expected)) * 100;

r = 0 - relative_error_percent;

end