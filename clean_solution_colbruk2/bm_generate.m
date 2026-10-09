% BM_GENERATE  Генерація «експериментальних» даних бенчмарком.
%
%   Збурення: на виході ділянки споживач за 15 хв зменшує відбір газу
%   на 15 %, а через три години так само за 15 хв повертає його назад;
%   компресорна станція на вході весь час тримає тиск за архівом.
%
%   Фон - архів у точках i0 ... i0+4 (8 год при кроці архіву 2 год),
%   лінійна інтерполяція на крок 1 хв.
%
%   Еталон - повна ізотермічна система з інерційним членом, метод
%   характеристик (bm_moc). Властивості газу - FGerg91, VisG1, тертя -
%   lyamColbr з ідентифікованою шорсткістю.
%
%   Вихід - файли того ж формату, що архів:
%     bm_P0_data.m  bm_pk_data.m  bm_Q_data.m  bm_RO0_data.m
%     bm_T1_data.m  bm_t2_data.m  bm_tg_data.m  bm_dt_data.m
%   читаються функцією getBmData (інтерфейс як у getExpData).
%   Витрата Q записується за лічильником на вході ділянки.
%
%   Температура не розв'язується: T1, t2, tg переносяться з архіву.
%
%   MATLAB R2023b.

clear; clc; close all;

%% 1. Параметри сценарію
i0      = 3305;            % точка архіву, з якої береться фон
nArch   = 4;               % інтервалів архіву по 2 год -> 8 год
dtArch  = 2*3600;          % с, крок архіву
dtData  = 60;              % с, крок згенерованих даних

tEvent1 = 1*3600;          % с, початок спаду відбору
tEvent2 = 4*3600;          % с, початок повернення відбору
tRamp   = 900;             % с, тривалість фронту
dropQ   = 0.15;            % частка зміни відбору

dxRef   = 500;             % м, крок сітки еталона
noiseP  = 0.02;            % атм, шум манометра перед квантуванням 0.1 атм
noiseQ  = 0.001;           % відносний шум витратоміра

Rsh = 0.042739e-3;         % м, ідентифікована шорсткість

%% 2. Ділянка і газ
L    = 122000;             % м
Dvn  = 1.388;              % м
S    = pi*Dvn^2/4;         % м^2
atm  = 101325;             % Па
xGas = [93.635 3.075 0.881 0.141 0.170 1.181 0.917 0]/100;
xa   = xGas(6);
xy   = xGas(7);
Rgas = 8314.472;           % Дж/(кмоль*К)
pc   = 101325;             % Па, стандартні умови
Tc   = 293.15;             % К

%% 3. Фон з архіву
ind = i0:(i0 + nArch);
[P0a, Qa, pka, ROa, T1a, t2a, tga] = getExpData(ind);

tArch = (0:nArch)'*dtArch;
t     = (0:dtData:nArch*dtArch)';

P0bg = interp1(tArch, P0a(:), t)*atm;      % Па
Qbg  = interp1(tArch, Qa(:),  t);          % тис. м^3/год
RObg = interp1(tArch, ROa(:), t);          % кг/м^3
T1bg = interp1(tArch, T1a(:), t);          % C
t2bg = interp1(tArch, t2a(:), t);          % C
tgbg = interp1(tArch, tga(:), t);          % K

qmBg = Qbg*1000/3600.*RObg;                % кг/с

%% 4. Збурення відбору на виході
f = 1 - dropQ*min(max((t - tEvent1)/tRamp, 0), 1) ...
      + dropQ*min(max((t - tEvent2)/tRamp, 0), 1);
qmOut = qmBg.*f;                           % кг/с

%% 5. Властивості газу для ізотермічного еталона
Tm = 273.15 + mean([t2a(:); T1a(:)]);      % К
pm = mean([P0a(:); pka(:)])*atm;           % Па

[~, Zm, zc] = FGerg91(pm/1e6, Tm, xa, xy, ROa(1));
Mm = ROa(1)*zc*Rgas*Tc/pc;                 % кг/кмоль
c2 = Zm*Rgas*Tm/Mm;                        % м^2/с^2
mu = VisG1(pm/1e6, Tm, xa, xy, ROa(1))*1e-6;   % Па*с

gas = struct('L', L, 'D', Dvn, 'S', S, 'c2', c2, 'mu', mu, 'Rsh', Rsh);

%% 6. Прогін еталона
bc.t  = t;
bc.p0 = P0bg;
bc.qL = qmOut;

ref = bm_moc(gas, bc, dxRef, t);

%% 7. Показання приладів (квантування як в архіві)
rng(1);
P0  = round((ref.p0/atm + noiseP*randn(size(t)))*10)/10;          % атм
pk  = round((ref.pL/atm + noiseP*randn(size(t)))*10)/10;          % атм
Q   = round(ref.q0./RObg*3.6.*(1 + noiseQ*randn(size(t))));       % тис. м^3/год
RO0 = round(RObg*1000)/1000;                                      % кг/м^3
T1  = round(T1bg);                                                % C
t2  = round(t2bg);                                                % C
tg  = round(tgbg);                                                % K

%% 8. Запис у форматі архіву
writeSeries('bm_P0_data.m',  'P0',  P0,  '%.1f');
writeSeries('bm_pk_data.m',  'pk',  pk,  '%.1f');
writeSeries('bm_Q_data.m',   'Q',   Q,   '%.0f');
writeSeries('bm_RO0_data.m', 'RO0', RO0, '%.3f');
writeSeries('bm_T1_data.m',  'T1',  T1,  '%.0f');
writeSeries('bm_t2_data.m',  't2',  t2,  '%.0f');
writeSeries('bm_tg_data.m',  'tg',  tg,  '%.0f');

fid = fopen('bm_dt_data.m', 'w');
fprintf(fid, 'dt = %d;   %% с, крок замірів\n', dtData);
fclose(fid);

save('bm_results.mat', 't', 'ref', 'bc', 'gas', 'i0', 'dtData', ...
     'tEvent1', 'tEvent2', 'tRamp', 'dropQ', 'noiseP', 'noiseQ');

%% 9. Звіт
fprintf('Фон: архів, точки %d ... %d\n', ind(1), ind(end));
fprintf('Газ: T = %.1f C, Z = %.4f, M = %.3f кг/кмоль, c = %.1f м/с\n', ...
        Tm - 273.15, Zm, Mm, ref.c);
fprintf('Еталон: dx = %.1f м, dt = %.3f с, кроків %d, L/c = %.0f с\n', ...
        ref.dx, ref.dt, ref.nt, L/ref.c);
fprintf('p(L) на старті: %.2f атм  (архів у точці %d: %.1f атм)\n', ...
        ref.pL(1)/atm, i0, pka(1));
fprintf('Записано %d замірів з кроком %d с у файли bm_*_data.m\n', numel(t), dtData);

bm_plotTrends;

%% ------------------------------------------------------------------------
function writeSeries(fname, vname, v, fmt)
% Запис ряду у форматі файлів архіву: vname = [ v1; v2; ... ];
fid = fopen(fname, 'w');
fprintf(fid, '%s = [\n', vname);
n = numel(v);
for k = 1:n
    if mod(k - 1, 10) == 0
        fprintf(fid, '  ');
    end
    fprintf(fid, [fmt ';'], v(k));
    if mod(k, 10) == 0 || k == n
        fprintf(fid, '\n');
    else
        fprintf(fid, ' ');
    end
end
fprintf(fid, '];\n');
fclose(fid);
end
