% plot_pipeline_data_subplots.m
% Load data from separate .m files and create subplots versus time.
% Compatible with MATLAB R2017.
clear; clc; close all;

% Location of the data files (assumed to be in the same folder as this script)
thisDir = fileparts(mfilename('fullpath'));
if isempty(thisDir); thisDir = pwd; end

% Load variables
run(fullfile(thisDir, 'P0_data.m'));
run(fullfile(thisDir, 'Q_data.m'));
run(fullfile(thisDir, 'pk_data.m'));
run(fullfile(thisDir, 'RO0_data.m'));
run(fullfile(thisDir, 'T1_data.m'));
run(fullfile(thisDir, 't2_data.m'));
run(fullfile(thisDir, 'tg_data.m'));
start = 11;
N = 21;

P0 = P0(start:N); 
Q = Q(start:N); 
pk = pk(start:N);
RO0 = RO0(start:N);
T1 = T1(start:N);
t2 = t2(start:N);
tg = tg(start:N);

% Check lengths
lens = [numel(P0), numel(Q), numel(pk), numel(RO0), numel(T1), numel(t2), numel(tg)];
assert(numel(unique(lens)) == 1, 'All series must have the same length.');
N = lens(1);

% Time vector (2-hour step)
time_hours = (0:N-1).' * 2;

% Define data arrays
data_vars = {P0, Q, pk, RO0, T1, t2, tg};
titles = {
    'Pressure at pipeline inlet';
    'Gas flow rate at standard conditions';
    'Pressure at pipeline outlet';
    'Gas density at standard conditions';
    'Gas temperature at pipeline inlet';
    'Gas temperature at pipeline outlet';
    'Ground temperature'
};
ylabels = {
    'P_0, atm';
    'Q, thous. m^{3}/day';
    'p_k, atm';
    '\rho_0, kg/m^{3}';
    't_1, C';
    't_2, C';
    't_g, K'
};

% ========== FIGURE 1: First 4 parameters ==========
fig1 = figure('Name', 'Pipeline Data - Part 1', 'Color', 'w', 'Position', [50, 100, 1200, 800]);

for i = 1:4
    subplot(2, 2, i);
    plot(time_hours, data_vars{i}, 'LineWidth', 1.5);
    grid on;
    title(titles{i}, 'FontSize', 11);
    ylabel(ylabels{i}, 'FontSize', 10);
    xlabel('t, hours', 'FontSize', 10);
end



% ========== FIGURE 2: Last 3 parameters ==========
fig2 = figure('Name', 'Pipeline Data - Part 2', 'Color', 'w', 'Position', [100, 50, 1200, 600]);

for i = 5:7
    subplot(2, 2, i-4);
    plot(time_hours, data_vars{i}, 'LineWidth', 1.5);
    grid on;
    title(titles{i}, 'FontSize', 11);
    ylabel(ylabels{i}, 'FontSize', 10);
    xlabel('t, hours', 'FontSize', 10);
end

