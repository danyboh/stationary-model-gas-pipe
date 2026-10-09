clc; clear; close all;
addpath('../functions', '../data');

% --- ідентифіковані параметри ---
kt  = 3.999574;             % Вт/(м^2*К)
Rsh = 0.042739 * 1e-3;      % м

% --- точка старту та вікно ---
i0     = 3305;              % початкова умова
W      = 36;                % 36 інтервалів по 2 год = 3 доби
ii_win = (i0 : i0+W).';     % 37 точок -> граничні умови у часі

% --- сітка по довжині ---
L  = 122000;
dx = 2000;
x  = (0:dx:L).';            % 62 вузли

% --- початкова умова: стаціонарний розв'язок у точці i0 ---
[P0, Q, pk, RO0, T1, t2, tg] = getExpData(i0);

y0   = [P0*101325, c2k_func(t2)];
Q1   = day2sec_func(Q);
opts = odeset('RelTol', 1e-8, 'AbsTol', [1e-2 1e-6]);

[~, y] = ode45(@(u,p) SystRivn_v_2_Danyl(u, p, Q1, kt, Rsh), x, y0, opts);

p_init  = y(:,1);           % Па
T_init  = y(:,2);           % К
PP_init = p_init.^2;        % P = p^2, Па^2 — змінна параболічної моделі

fprintf('Початкові профілі побудовано за точкою %d\n', i0);
fprintf('  p(0) = %.2f атм,  p(L) = %.2f атм\n', p_init(1)/101325, p_init(end)/101325);
fprintf('  T(0) = %.2f C,    T(L) = %.2f C\n',   k2c_func(T_init(1)), k2c_func(T_init(end)));
fprintf('  Q    = %.0f тис.м3/год,  вузлів %d, dx = %.0f м\n', Q, numel(x), dx);

% --- граничні умови на вікні (для етапу 2) ---
[P0w, Qw, pkw, ~, T1w, t2w, ~] = getExpData(ii_win);
t_bc = (0:W).' * 2 * 3600;      % с від старту

save('init_3305.mat', 'i0', 'x', 'dx', 'L', ...
     'p_init', 'T_init', 'PP_init', ...
     'ii_win', 't_bc', 'P0w', 'Qw', 'pkw', 'T1w', 't2w', 'kt', 'Rsh');

% --- рисунок 1: розподіл тиску ---
figure('Color', 'w');
plot(x/1000, p_init/101325, 'b', 'LineWidth', 1.4);
xlabel('x, км'); ylabel('p, атм');
xlim([0 L/1000]); grid on

% --- рисунок 2: розподіл температури ---
figure('Color', 'w');
plot(x/1000, k2c_func(T_init), 'r', 'LineWidth', 1.4);
xlabel('x, км'); ylabel('T, ^\circC');
xlim([0 L/1000]); grid on