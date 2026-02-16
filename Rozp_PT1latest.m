clc; clear;
addpath('functions', 'data');
u0=0; uf=122000;
[P0_atm, Q, pEnd_atm, ro, ~, tempGasStart, ~] = getExpDataFunc(5);
p0 = atm2pa_func(P0_atm); % convert to Pa
options = odeset('RelTol', 1e-6, 'AbsTol', 1e-9, 'MaxStep', 100);
Qsec = day2sec_func(Q); % from m3/day to m3/s
%best for point 5 = 0.0091789810
[u,y]=ode45(@(u,p) Rozrax_Cp_Func(u,p, Qsec, ro, tempGasStart, 0.0062230071),[u0 uf], p0, options);
% Convert pressure from Pa to atm (1 atm = 101325 Pa)
p_atm = y / 101325;

% Calculate final pressure and error analysis
p_final_calculated = p_atm(end);  % Last calculated pressure value
p_final_expected = pEnd_atm;      % Expected final pressure

% Calculate errors
absolute_error = p_final_calculated - p_final_expected;
relative_error_percent = (absolute_error / (P0_atm - p_final_expected)) * 100;

% Display results
fprintf('\n=== PRESSURE DROP ANALYSIS ===\n');
fprintf('Initial Pressure (P0):     %.4f atm\n', P0_atm);
fprintf('Expected Final Pressure:   %.4f atm\n', p_final_expected);
fprintf('Calculated Final Pressure: %.4f atm\n', p_final_calculated);
fprintf('Absolute Error:            %.4f atm\n', absolute_error);
fprintf('Relative Error:            %.2f%%\n', relative_error_percent);
fprintf('Expected Pressure Drop:    %.4f atm\n', P0_atm - p_final_expected);
fprintf('Calculated Pressure Drop:  %.4f atm\n', P0_atm - p_final_calculated);
fprintf('===============================\n');

figure (1); plot(u, p_atm); grid; title('Pressure along Pipeline'); 
xlabel('Distance (m)'); ylabel('Pressure (atm)');