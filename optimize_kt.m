clc; clear; close all;
addpath('functions', 'data');

opts_ode = odeset('RelTol',1e-7,'AbsTol',1e-9);
opts_opt = optimoptions('lsqnonlin','Display','iter','FunctionTolerance',1e-10,'StepTolerance',1e-10,'OptimalityTolerance',1e-10);
a = lsqnonlin(@(a) R(a), 1.75, 0.5, 10, opts_opt);

fprintf('===============================\n');
fprintf('Optimized kt:     %.10f\n', a);

function r = R(a)
    u0=0; uf=122000;
    TExpCels = 26;
    options = odeset('RelTol', 1e-6, 'AbsTol', 1e-9, 'MaxStep', 100);
    Q1=day2sec_func(3506);
    P0_atm = 66.6;
    p1 = P0_atm*101325;   % Pa
    T1 = 273.15+40;
    y0=[p1 T1];
    [u,y]=ode45(@(u,p) SystRivn_v_2_Danyl_Func(u,p, Q1, 1.64, a),[u0 uf], y0, options);
    % Convert temperature from K to C
    t_c = k2c_func(y(:,2));

    % Calculate final temperature and error analysis
    t_final_calculated = t_c(end);
    t_final_expected = TExpCels;

    % Calculate errors
    absolute_error = t_final_calculated - t_final_expected;
    relative_error_percent = (absolute_error / (t_final_expected)) * 100;

    r = 0 - relative_error_percent;

end
