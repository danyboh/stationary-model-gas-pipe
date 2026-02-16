function [pInp, Qv, pEnd, ro, tempEnd, tempStart, tempGround] = getExpDataFunc(ind)

thisDir = fileparts(mfilename('fullpath'));
if isempty(thisDir); thisDir = pwd; end
dataDir = fullfile(thisDir, '..', 'data');

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

pInp = P0(ind); % atm
Qv = Q(ind); %m3/s
pEnd = pk(ind); %atm
ro = RO0(ind); % kg/m3
tempEnd = T1(ind); % C - not mistake
tempStart = t2(ind); % C - not mistake
tempGround = tg(ind); % K
