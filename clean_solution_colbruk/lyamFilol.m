function lyamda = lyamFilol(Re, k)
% Коефіцієнт гідравлічного опору за формулою Філоненка
% (гідравлічно гладка труба)
%   Re - число Рейнольдса
%   k  - емпірична стала (класичне значення 1.64)
% Джерело: Idelchik I.E. Handbook of Hydraulic Resistance,
%          4th ed., Begell House, 2007, с. 93, рівн. (2.8)

    lyamda = (0.79*log(Re) - k).^(-2);
end