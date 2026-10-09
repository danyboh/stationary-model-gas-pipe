function [pInp, Qv, pEnd, ro, tempEnd, tempStart, tempGround, tSec] = getBmData(ind)
%GETBMDATA Читання згенерованого бенчмарком набору даних.
%
%   Інтерфейс той самий, що в getExpData, плюс восьмий вихід - час, с.
%   Без аргументу повертає весь ряд.
%
%   pInp       - тиск на вході, атм
%   Qv         - витрата за лічильником на вході, тис. м^3/год
%   pEnd       - тиск на виході, атм
%   ro         - густина за стандартних умов, кг/м^3
%   tempEnd    - температура на виході, C
%   tempStart  - температура на вході, C
%   tempGround - температура ґрунту, K
%   tSec       - час від початку запису, с

thisDir = fileparts(mfilename('fullpath'));
if isempty(thisDir); thisDir = pwd; end

run(fullfile(thisDir, 'bm_P0_data.m'));
run(fullfile(thisDir, 'bm_Q_data.m'));
run(fullfile(thisDir, 'bm_pk_data.m'));
run(fullfile(thisDir, 'bm_RO0_data.m'));
run(fullfile(thisDir, 'bm_T1_data.m'));
run(fullfile(thisDir, 'bm_t2_data.m'));
run(fullfile(thisDir, 'bm_tg_data.m'));
run(fullfile(thisDir, 'bm_dt_data.m'));

lens = [numel(P0), numel(Q), numel(pk), numel(RO0), numel(T1), numel(t2), numel(tg)];
assert(numel(unique(lens)) == 1, 'Усі ряди мають бути однакової довжини.');

if nargin < 1 || isempty(ind)
    ind = 1:numel(P0);
end

pInp       = P0(ind);
Qv         = Q(ind);
pEnd       = pk(ind);
ro         = RO0(ind);
tempEnd    = T1(ind);
tempStart  = t2(ind);
tempGround = tg(ind);
tSec       = (ind(:) - 1)*dt;

end
