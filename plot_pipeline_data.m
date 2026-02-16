% plot_pipeline_data_separate.m
% Load data from separate .m files and create individual plots versus time.
% Compatible with MATLAB R2017.

clear; clc; close all;
addpath('functions', 'data');

% Location of the data files
thisDir = fileparts(mfilename('fullpath'));
if isempty(thisDir); thisDir = pwd; end
dataDir = fullfile(thisDir, 'data');

% Load variables
run(fullfile(dataDir, 'P0_data.m'));
run(fullfile(dataDir, 'Q_data.m'));
run(fullfile(dataDir, 'pk_data.m'));
run(fullfile(dataDir, 'RO0_data.m'));
run(fullfile(dataDir, 'T1_data.m'));
run(fullfile(dataDir, 't2_data.m'));
run(fullfile(dataDir, 'tg_data.m'));

% Check lengths
lens = [numel(P0), numel(Q), numel(pk), numel(RO0), numel(T1), numel(t2), numel(tg)];
assert(numel(unique(lens)) == 1, 'All series must have the same length.');
N = lens(1);

% Time vector (2-hour step)
time_hours = (0:N-1).' * 2;
time_days  = time_hours / 24;
span_days  = max(time_days) - min(time_days);

% Decide x-axis units
use_months = span_days >= 60;
if use_months
    time_x = time_days / 30.4375; % average month length
    xlab = 'Time (months)';
    total_months = floor(span_days / 30.4375 * 100) / 100; % 2 decimal precision
    x_max = total_months; % limit to ~10 months
    xticks_vals = 0 : 1 : ceil(total_months);
else
    time_x = time_days;
    xlab = 'Time (days)';
    total_days = floor(span_days * 100) / 100;
    x_max = total_days;
    xticks_vals = 0 : 7 : ceil(total_days);
end

% Print summary
fprintf('Samples: %d\n', N);
fprintf('Step: 2 hours\n');
fprintf('Total span: %.2f days (%.2f months)\n', span_days, span_days / 30.4375);

% Create each plot with x-axis limited to actual span
make_plot(time_x, P0, 'P0',  'atm',        xlab, xticks_vals, x_max, '���� �� ���� � ����������, ���');
make_plot(time_x, Q,  'Q',   'm^3/s (STP)',xlab, xticks_vals, x_max, '�ᒺ��� ������� ������� �� ����������� ����, �3/���');
make_plot(time_x, pk, 'pk',  'atm',        xlab, xticks_vals, x_max, '���� � ���� ����������� (���� �� ����� ����������� �������) ���');
make_plot(time_x, RO0,'RO0', 'kg/m^3',     xlab, xticks_vals, x_max, '������� ���� �� ����������� ����, ��/�3');
make_plot(time_x, T1, 'T1',  '�C',         xlab, xticks_vals, x_max, '����������� ���� � ���� �����������, ����. �');
make_plot(time_x, t2, 't2',  '�C',         xlab, xticks_vals, x_max, '����������� ���� �� ������� �����������, ����.�');
make_plot(time_x, tg, 'tg',  'K',          xlab, xticks_vals, x_max, '����������� ������, �');

% -------- Local function --------
function make_plot(x, y, nameStr, yunit, xlab, xticks_vals, x_max, t)
    f = figure('Name', sprintf('%s', nameStr), 'Color', 'w');
    plot(x, y, 'LineWidth', 1.25);
    grid on;
    xlabel(xlab);
    ylabel(sprintf('%s (%s)', nameStr, yunit));
    title(t);
    if ~isempty(xticks_vals)
        set(gca, 'XTick', xticks_vals);
    end
    xlim([0, x_max]);
end
