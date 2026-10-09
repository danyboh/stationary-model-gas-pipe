% BM_PLOTTRENDS  Тренди згенерованого набору - показання приладів у часі.
%
%   Читає bm_*_data.m через getBmData і будує те, що показав би архів
%   SCADA: тиск на вході, тиск на виході, витрату.
%
%   MATLAB R2023b.

[P0, Q, pk, ~, ~, ~, ~, tSec] = getBmData();
th = tSec/3600;

figure('Color', 'w', 'Name', 'Згенеровані виміри', 'Position', [100 80 900 720]);

ax1 = subplot(3,1,1);
plot(th, P0, '.-', 'MarkerSize', 6);
grid on; ylabel('P0, атм');
title('Тиск на вході');

ax2 = subplot(3,1,2);
plot(th, pk, '.-', 'MarkerSize', 6);
grid on; ylabel('pk, атм');
title('Тиск на виході');

ax3 = subplot(3,1,3);
plot(th, Q, '.-', 'MarkerSize', 6);
grid on; ylabel('Q, тис. м^3/год'); xlabel('t, год');
title('Витрата (лічильник на вході)');

linkaxes([ax1 ax2 ax3], 'x');
xlim([th(1) th(end)]);

print(gcf, '-dpng', '-r150', 'fig_bm_trends');
