clc; clear; close all;

ii_fit = [ 337 ...
 %  358   539  1039  1473  1476  1479  1751 ...
  % 1801  2127  2151  2181  2405  2521  2541  2575 ...
  % 2707  2808  2833  2880  2917  2944  3144  3167 ...
  % 3195  3458  3646 ...
];

% --- дані завантажуємо ОДИН раз ---
[DATA.P0, DATA.Q, DATA.pk, DATA.RO0, DATA.T1, DATA.t2, DATA.tg] = getExpData(ii_fit);

% --- невизначеності вимірювань (крок квантування запису) ---
DATA.sigP = 0.1;    % атм
DATA.sigT = 1.0;    % C

% --- опції інтегрування: точність має бути на порядки вища за нев'язки ---
DATA.odeopts = odeset('RelTol', 1e-9, 'AbsTol', [1e-3 1e-6]);

%          kt      Rsh, мм
x0 = [    3.5  ,   0.03  ];
lb = [    1.0  ,   0.005 ];
ub = [    4.0  ,   0.30  ];

options = optimoptions('fmincon', ...
    'TolX', 1e-8, 'TolFun', 1e-10, ...
    'FiniteDifferenceStepSize', 1e-4, ...   % крок різниць > шуму інтегрування
    'MaxIter', 500, 'Display', 'iter');

x_opt = fmincon(@(x) R(x, DATA), x0, [], [], [], [], lb, ub, [], options);

fprintf('===============================\n');
fprintf('Optimized kt:   %.6f Вт/(м^2*К)\n', x_opt(1));
fprintf('Optimized Rsh:  %.6f мм\n',          x_opt(2));

% --- розклад нев'язки по точках при оптимумі ---
[~, det] = R(x_opt, DATA);
fprintf('\n  i     P_вим   P_розр   dP,атм    T_вим  T_розр   dT,C\n');
for i = 1:numel(det.pc)
    fprintf('%5d  %6.2f  %6.2f  %+7.3f    %5.1f  %5.1f  %+6.2f\n', ...
        ii_fit(i), DATA.pk(i), det.pc(i), det.pc(i)-DATA.pk(i), ...
        DATA.T1(i), det.tc(i), det.tc(i)-DATA.T1(i));
end
fprintf('\nRMS по тиску:       %.4f атм\n', sqrt(mean((det.pc-DATA.pk).^2)));
fprintf('RMS по температурі: %.4f C\n',   sqrt(mean((det.tc-DATA.T1).^2)));

% --- зріз цільової функції по kt (діагностика форми) ---
% fprintf('\nзріз по kt при Rsh = %.4f мм:\n', x_opt(2));
% for kt = lb(1):0.25:ub(1)
%     fprintf('  kt=%.2f  err=%.4f\n', kt, R([kt, x_opt(2)], DATA));
% end


function [err, det] = R(x, D)
    kt  = x(1);
    Rsh = x(2)*1e-3;              % мм -> м

    u0 = 0; uf = 122000;
    n  = numel(D.P0);
    pc = zeros(n,1); tc = zeros(n,1);

    for i = 1:n
        y0 = [D.P0(i)*101325, c2k_func(D.t2(i))];
        Q1 = day2sec_func(D.Q(i));
        try
            [~, y] = ode45(@(u,p) SystRivn_v_2_Danyl(u, p, Q1, kt, Rsh), ...
                           [u0 uf], y0, D.odeopts);
            if any(y(:,1) < 0) || any(isnan(y(:)))
                err = 1e10; det = []; return
            end
        catch ME
            fprintf('!! %s\n', ME.message);
            err = 1e10; det = []; return
        end
        pc(i) = y(end,1)/101325;
        tc(i) = k2c_func(y(end,2));
    end

    errP = sum(((pc - D.pk)/D.sigP).^2);
    errT = sum(((tc - D.T1)/D.sigT).^2);
    err  = (errP + errT)/n;

    det.pc = pc;  det.tc = tc;  det.errP = errP/n;  det.errT = errT/n;
    fprintf('kt=%.4f  Rsh=%.4f мм  err=%.4f  (P:%.4f  T:%.4f)\n', ...
            kt, x(2), err, errP/n, errT/n);
end