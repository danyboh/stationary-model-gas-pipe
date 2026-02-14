clc; clear; close all;

P0 = [66.6; 66.5; 66.4; 66.2; 66.1];


Q = [3506; 3492; 3484; 3479; 3459];


Pk = [48.5; 48.3; 48.3; 48.2; 48.0];

percentErrorArr = 1:numel(P0);
absoluteErrors = 1:numel(P0);
p_calculated = 1:numel(P0);

for i=1:numel(P0)
    [p_final_calculated, relative_error_percent, absolute_error] = calcBaseWithValuesFunc(3.57254168, P0(i), Q(i), Pk(i));
    percentErrorArr(i) = relative_error_percent;
    absoluteErrors(i) = absolute_error;
    p_calculated(i) = p_final_calculated;
    
end


fprintf('===============================\n');

figure (1); plot(1:numel(percentErrorArr), percentErrorArr); grid;
xlabel('Point'); ylabel('%');

figure (2); plot(1:numel(absoluteErrors), absoluteErrors); grid; 
xlabel('Point'); ylabel('atm');