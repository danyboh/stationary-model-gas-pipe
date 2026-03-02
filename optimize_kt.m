clc; clear; close all;
addpath('functions', 'data');

a = fminbnd(@(a) R(a), 1222222222222222, 12222222222222222);

fprintf('===============================\n');
fprintf('Optimized kt:     %.10f\n', a);

%optimized value will be this 2880108422671461

function err = R(a)
    u0=0; uf=122000;
    TExpCels = 26;
    options = odeset('RelTol', 1e-6, 'AbsTol', 1e-9, 'MaxStep', 100);
    Q1=day2sec_func(3506);
    P0_atm = 66.6;
    p1 = P0_atm*101325;   % Pa
    T1 = 273.15+40;
    y0=[p1 T1];
    [u,y]=ode45(@(u,p) SystRivn_v_2_Danyl_Func(u,p, Q1, 1.64, a),[u0 uf], y0, options);
    t_c = k2c_func(y(:,2));

    t_final_calculated = t_c(end);
    absolute_error = t_final_calculated - TExpCels;
    err = absolute_error^2;
    fprintf('kt=%.6f  T_calc=%.4f C  err=%.6f\n', a, t_final_calculated, err);
end
