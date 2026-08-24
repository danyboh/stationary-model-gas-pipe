clc; clear; close all;
addpath('../functions', '../data');

a = fminbnd(@(a) R(a), 1.75, 4);

fprintf('===============================\n');
fprintf('Optimized kt:     %.10f\n', a);

%optimized value will be this 2880108422671461

function err = R(a)
    u0=0; uf=122000;
    TExpCels = 26;
    P0_atm = 66.5;
    p1 = P0_atm*101325;   % Pa
    T1 = 273.15+40;
    Q1 = day2sec_func(3492);
    y0=[p1 T1];
    [u,y]=ode45(@(u,p) SystRivn_v_2_Danyl(u,p,Q1,a),[u0 uf], y0);
    t_c = k2c_func(y(:,2));

    t_final_calculated = t_c(end);
    absolute_error = t_final_calculated - TExpCels;
    err = absolute_error^2;
    fprintf('kt=%.6f  T_calc=%.4f C  err=%.6f\n', a, t_final_calculated, err);
end
