clc; clear; close all;
addpath('../functions', '../data');

% --- поріг відсіювання викидів ---
errThreshold = 10;          % %, точки з |відн. похибки тиску| > errThreshold відкидаються

% --- ідентифіковані параметри ---
kt  = 3.999574;             % Вт/(м^2*К)
Rsh = 0.042739 * 1e-3;      % м

% --- які точки рахувати ---
step   = 1;                          % 1 = всі; 5 = кожна п'ята (швидше)
ii_all = (1:step:3663).';

[P0, Q, pk, RO0, T1, t2, tg] = getExpData(ii_all);

n    = numel(ii_all);
opts = odeset('RelTol', 1e-8, 'AbsTol', [1e-2 1e-6]);
u0   = 0;  uf = 122000;

p_calc = nan(n,1);
t_calc = nan(n,1);

fprintf('Розрахунок %d точок...\n', n);
tic
for i = 1:n
    y0 = [P0(i)*101325, c2k_func(t2(i))];
    Q1 = day2sec_func(Q(i));
    try
        [~, y] = ode45(@(u,p) SystRivn_v_2_Danyl(u, p, Q1, kt, Rsh), ...
                       [u0 uf], y0, opts);
        if any(y(:,1) < 0) || any(isnan(y(:)))
            continue
        end
        p_calc(i) = y(end,1)/101325;
        t_calc(i) = k2c_func(y(end,2));
    catch ME
        fprintf('точка %d: %s\n', ii_all(i), ME.message);
    end
    if mod(i, 200) == 0
        fprintf('  %d / %d   (%.1f с)\n', i, n, toc);
    end
end
fprintf('Готово за %.1f с\n\n', toc);

% --- похибки ---
dP_abs = p_calc - pk;                 % атм
dT_abs = t_calc - T1;                 % C
dP_rel = dP_abs ./ pk * 100;          % %
dT_rel = dT_abs ./ T1 * 100;          % %
t_days = (ii_all - 1) * 2 / 24;       % час, доби (крок 2 год)
ok = ~isnan(p_calc);

% --- статистика до фільтрації ---
mP0 = mean(dP_rel(ok));  sP0 = std(dP_rel(ok));
mT0 = mean(dT_rel(ok));  sT0 = std(dT_rel(ok));

% --- відсіювання викидів за порогом похибки тиску ---
isOutlier = ok & abs(dP_rel) > errThreshold;
keep      = ok & ~isOutlier;
idxOut    = find(isOutlier);

mP = mean(dP_rel(keep));  sP = std(dP_rel(keep));
mT = mean(dT_rel(keep));  sT = std(dT_rel(keep));

% --- підсумок фільтрації ---
fprintf('=== ФІЛЬТРАЦІЯ (|відн. похибка тиску| > %g %%) ===\n', errThreshold);
fprintf('точок до фільтрації:    %d\n', sum(ok));
fprintf('точок після фільтрації: %d\n', sum(keep));
fprintf('відкинуто точок:        %d\n', numel(idxOut));
for k = 1:numel(idxOut)
    j = idxOut(k);
    fprintf('  точка %5d (індекс %5d): доба %8.3f, dp = %+8.3f %%, dT = %+8.3f %%\n', ...
            ii_all(j), j, t_days(j), dP_rel(j), dT_rel(j));
end

% --- підсумок ---
fprintf('\n=== ТИСК ===\n');
fprintf('                         до фільтр.   після фільтр.\n');
fprintf('середня відн. похибка: %+9.3f %%   %+9.3f %%\n', mP0, mP);
fprintf('СКВ відн. похибки:      %9.3f %%    %9.3f %%\n', sP0, sP);
fprintf('макс. |відн. похибки|:  %9.3f %%    %9.3f %%\n', ...
        max(abs(dP_rel(ok))), max(abs(dP_rel(keep))));
fprintf('СКВ абс. похибки:       %9.4f атм  %9.4f атм\n', ...
        std(dP_abs(ok)), std(dP_abs(keep)));

fprintf('\n=== ТЕМПЕРАТУРА ===\n');
fprintf('                         до фільтр.   після фільтр.\n');
fprintf('середня відн. похибка: %+9.3f %%   %+9.3f %%\n', mT0, mT);
fprintf('СКВ відн. похибки:      %9.3f %%    %9.3f %%\n', sT0, sT);
fprintf('макс. |відн. похибки|:  %9.3f %%    %9.3f %%\n', ...
        max(abs(dT_rel(ok))), max(abs(dT_rel(keep))));
fprintf('СКВ абс. похибки:       %9.4f C    %9.4f C\n', ...
        std(dT_abs(ok)), std(dT_abs(keep)));
fprintf('точок не розраховано:   %d\n', sum(~ok));

% --- відфільтровані дані ---
ii_f     = ii_all(keep);
t_days_f = t_days(keep);
Q_f      = Q(keep);
dP_abs_f = dP_abs(keep);
dT_abs_f = dT_abs(keep);
dP_rel_f = dP_rel(keep);
dT_rel_f = dT_rel(keep);

save('errors_all_points_filtered.mat', 'ii_all', 'P0', 'Q', 'pk', 'T1', 't2', ...
     'p_calc', 't_calc', 'dP_abs', 'dT_abs', 'dP_rel', 'dT_rel', 'kt', 'Rsh', ...
     'errThreshold', 'ok', 'keep', 'isOutlier', 'idxOut', ...
     'ii_f', 't_days_f', 'dP_abs_f', 'dT_abs_f', 'dP_rel_f', 'dT_rel_f', ...
     'mP0', 'sP0', 'mT0', 'sT0', 'mP', 'sP', 'mT', 'sT');

%% --- рисунок 1: відносна похибка по тиску ---
figure('Name', 'Відносна похибка тиску', 'Color', 'w');
h1 = plot(t_days_f, dP_rel_f, '-', 'Color', [0.6 0.6 0.6], 'LineWidth', 0.5);
grid on
xlim([0 300]);
hline(0,       'k-',  0.8);
h2 = hline(mP, '-', 2, 'Color', [0.75 0.10 0.10]);
h3 = hline(mP + sP, 'k--', 1.5);
     hline(mP - sP, 'k--', 1.5);
hold off
xlabel('t, доба'); ylabel('\deltap, %');
legend({'$\delta p$', '$\overline{\delta p}$', '$\overline{\delta p} \pm \sigma$'}, ...
       'Interpreter', 'latex', 'FontSize', 11, 'Location', 'northeast');
%% --- рисунок 2: відносна похибка по температурі ---
figure('Name', 'Відносна похибка температури', 'Color', 'w');
h1 = plot(t_days_f, dT_rel_f, 'r', 'LineWidth', 0.8);
grid on
hline(0,       'k-',  0.8);
h2 = hline(mT, 'b--', 1.2);
h3 = hline(mT + sT, 'b:', 1.0);
     hline(mT - sT, 'b:', 1.0);
hold off
xlabel('Час, доби'); ylabel('Відносна похибка температури, %');
title(sprintf('Температура на виході: середня %+.3f %%, СКВ %.3f %%', mT, sT));
legend([h1 h2 h3], 'похибка', 'середнє', '\pm СКВ', 'Location', 'best');

%% --- рисунок 3: абсолютні похибки ---
figure('Name', 'Абсолютні похибки', 'Color', 'w');
subplot(2,1,1);
plot(t_days_f, dP_abs_f, 'b', 'LineWidth', 0.8); grid on
hline(0, 'k-', 0.8); hold off
xlabel('Час, доби'); ylabel('\Deltap, атм');
title('Абсолютна похибка тиску на виході');

subplot(2,1,2);
plot(t_days_f, dT_abs_f, 'r', 'LineWidth', 0.8); grid on
hline(0, 'k-', 0.8); hold off
xlabel('Час, доби'); ylabel('\DeltaT, ^\circC');
title('Абсолютна похибка температури на виході');

%% --- рисунок 4: похибка проти витрати ---
figure('Name', 'Похибка проти витрати', 'Color', 'w');
subplot(1,2,1);
plot(Q_f, dP_rel_f, '.b', 'MarkerSize', 4); grid on
hline(0, 'k-', 0.8); hold off
xlabel('Q, тис. м^3/год'); ylabel('Відн. похибка тиску, %');
title('Тиск');

subplot(1,2,2);
plot(Q_f, dT_rel_f, '.r', 'MarkerSize', 4); grid on
hline(0, 'k-', 0.8); hold off
xlabel('Q, тис. м^3/год'); ylabel('Відн. похибка температури, %');
title('Температура');


%% ================= локальна функція =================
function h = hline(yv, style, lw, varargin)
% Горизонтальна лінія на поточних осях (заміна yline для MATLAB < R2018b)
    xl = get(gca, 'XLim');
    hold on
    h = plot(xl, [yv yv], style, 'LineWidth', lw, varargin{:});
    set(gca, 'XLim', xl);
end
