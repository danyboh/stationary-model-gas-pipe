clc, clear;
addpath('../functions', '../data');
%--------------------------------------------------------------------------
% РОЗПОДІЛ ТИСКУ І ТЕМЕРАТУРИ ПО ДОВЖИНІ ТРУБОПРОВОДУ
% p1 = 101325+3.4*98066.5;   % Pa, тиск газу на вході ПРП2
p1 = 66.5*101325;   % Pa, тиск газу на вході
T1 = 273.15+40;   % K, температура газу 
Q1=970.49;      %m^3/sec (за с.у.)
%Q1=191200;      %m^3/god (за с.у.)
L=122000;        % m
Dvn=1.388;      % m
Dz=1.428;       % m
 % x = [Metan   Etan   Propan  n-Butan  i-Butan  Azot  CO2  H2S]
   x = [93.635  3.075  0.881   0.141    0.170   1.181  0.917  0]/100;   
 Roc=0.682;     % kg/m^3
 g=9.81;         % m/c^2
 R=8314.472;     % Dg/(kMol*K), газова стала
 
l0=0; lf=122000;  % m, початкова і кінцева відстань 
y0=[p1 T1]; % початкові умови
[l,y]=ode45(@(u,y) SystRivn_v_2_Danyl(u,y, Q1, 1.000186, 0.029260 *1e-3),[l0 lf], y0)
%[l,y]=ode45('SystRivn_v_2_Danyl',[l0 lf],y0, Q1);

n=size(y);
px=y(n(1),1);   % Pa, тиск на станції №2
Tx=y(n(1),2);   % K, температура на станції №2
%--------------------------------------------------------------------------
% розрахунок витрати в місці аварії
P_b=101325.0;       % Pa   
my_r=0.588*(P_b/px)^3-0.983*(P_b/px)^2+0.163*(P_b/px)+0.843;
F=pi*Dvn^2/4;
F_ot=1*F;
p=px/1e6;           % MPa
T=Tx;               % K
% функція для розрахунку коефіцієнта стисливості
% модифікованим рівнянням GERG-91 мод. (ГОСТ 30319,2)
xa = x(6); xy = x(7);
[Kgerg,z,zc]=FGerg91(p,T,xa,xy,Roc);

Qr = Q1*101325/p1*T1/293.15*Kgerg ;  % витрата в роб умовах приблизна (для р1, Т1)
v = Qr/F;                           % швидкість потоку, м/сек

if (P_b/px)>0.54
    Qcx=0.1564*my_r*F_ot*px*sqrt(1/(Roc*Tx*Kgerg)*((P_b/px)^1.53-(P_b/px)^1.77));
else
    Qcx=0.0359*my_r*F_ot*px/sqrt(Tx*Kgerg*Roc);
end
Qcx=Qcx*3600;
Q1=Q1-Qcx;
%--------------------------------------------------------------------------
% % РОЗПОДІЛ ТИСКУ І ТЕМЕРАТУРИ ПО ДОВЖИНІ ТРУБОПРОВОДУ
% l0=6150; lf=10000;  % m, початкова і кінцева відстань 
% y0=[px Tx]; % початкові умови
% [l1,y1]=ode45('SystRivn_v_2',[l0 lf],y0);
%figure(3), plot(l,y(:,1)./101325), xlabel('L,м'), ylabel('p,Па'), grid
% figure(4), plot(l,y(:,2)-273.15), xlabel('L,м'), ylabel('Т,К'), grid     %  ,Tx,'*',lf
% figure(3), plot(l,y(:,1),l1,y1(:,1),6150,px,'*'), xlabel('L,м'), ylabel('p,Па'), grid
% figure(4), plot(l,y(:,2),l1,y1(:,2),6150,Tx,'*'), xlabel('L,м'), ylabel('Т,К'), grid
p_atm = y(:,1) / 101325;
t_c = k2c_func(y(:,2)); 
pEnd_atm = 48.3;
TExpCels = 26; % C
T1Cels = 40; % C 
T1 = c2k_func(T1Cels); 

% Pressure error analysis
p_final_calculated = p_atm(end);
absolute_error_p = p_final_calculated - pEnd_atm;
relative_error_p = (absolute_error_p / pEnd_atm) * 100;

% Temperature error analysis
t_final_calculated = t_c(end);
absolute_error_t = t_final_calculated - TExpCels;
relative_error_t = (absolute_error_t / TExpCels) * 100;

% Display results
fprintf('\n=== PRESSURE DROP ANALYSIS ===\n');
fprintf('Initial Pressure (P0):     %.4f atm\n', p1);
fprintf('Expected Final Pressure:   %.4f atm\n', pEnd_atm);
fprintf('Calculated Final Pressure: %.4f atm\n', p_final_calculated);
fprintf('Absolute Error:            %.4f atm\n', absolute_error_p);
fprintf('Relative Error:            %.2f%%\n', relative_error_p);
fprintf('Expected Pressure Drop:    %.4f atm\n', p1 - pEnd_atm);
fprintf('Calculated Pressure Drop:  %.4f atm\n', p1 - p_final_calculated);

fprintf('\n=== TEMPERATURE ANALYSIS ===\n');
fprintf('Initial Temperature:        %.4f C\n', T1Cels);
fprintf('Expected Final Temperature: %.4f C\n', TExpCels);
fprintf('Calculated Final Temperature:%.4f C\n', t_final_calculated);
fprintf('Absolute Error:             %.4f C\n', absolute_error_t);
fprintf('Relative Error:             %.2f%%\n', relative_error_t);
fprintf('===============================\n');

%--------------------------------------------------------------------------
figure(1);
subplot(1,2,1);
plot(l, p_atm, 'b', 'LineWidth', 1.5);
hold on;
plot(l(end), pEnd_atm, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
hold off;
xlabel('L, m'); ylabel('P, atm');
legend('Розрахований розподіл', 'Експериментальне значенння');
grid on;

subplot(1,2,2);
plot(l, t_c, 'r', 'LineWidth', 1.5);
hold on;
plot(l(end), TExpCels, 'bo', 'MarkerSize', 8, 'LineWidth', 2);
hold off;
xlabel('L, m'); ylabel('t, C');
legend('Розрахований розподіл', 'Експериментальне значенння');
grid on;


