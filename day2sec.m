function Q_sec = day2sec(Q_thousands)
%DAY2SEC ѕереводить витрату з м3/добу у м3/с
%
%   Q_sec = day2sec(Q_day)
%
%   Q_day Ц витрата у м?/добу
%   Q_sec Ц витрата у м?/с
    Q_sec = Q_thousands * 1000 / (3600);
end