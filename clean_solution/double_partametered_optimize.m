clc; clear; close all;
addpath('../functions', '../data');

x0 = [2.88, 3.736];
lb = [1.0, 1.0];   % lower bounds: [kt, lconst]
ub = [4.0, 4.0];   % upper bounds: [kt, lconst]

options = optimoptions('fmincon', 'TolX', 1e-6, 'TolFun', 1e-8, ...
                        'MaxIter', 500, 'Display', 'iter');

x_opt = fmincon(@(x) R(x), x0, [], [], [], [], lb, ub, [], options);

fprintf('===============================\n');
fprintf('Optimized kt:           %.10f\n', x_opt(1));
fprintf('Optimized lyamda_const: %.10f\n', x_opt(2));

function err = R(x)
    kt     = x(1);
    lconst = x(2);

    u0 = 0; uf = 122000;
    TExpCels = 26;
    pExpAtm  = 48.3;
    p1       = 66.5 * 101325;
    T1       = 273.15 + 40;
    Q1       = day2sec_func(3492);
    y0       = [p1 T1];

    try
        [~, y] = ode45(@(u,p) SystRivn_v_2_Danyl(u, p, Q1, kt, lconst), [u0 uf], y0);

        if any(y(:,1) < 0) || any(isnan(y(:,1))) || any(isnan(y(:,2)))
            err = 1e10;
            return;
        end

        p_final_atm = y(end, 1) / 101325;
        t_final     = k2c_func(y(end, 2));

        err_T = (t_final     - TExpCels) / TExpCels;
        err_P = (p_final_atm - pExpAtm)  / pExpAtm;
        err   = err_T^2 + err_P^2;

        fprintf('kt=%.4f  lc=%.4f  P=%.3f atm  T=%.3f C  err=%.8f\n', ...
                kt, lconst, p_final_atm, t_final, err);
    catch
        err = 1e10;
    end
end