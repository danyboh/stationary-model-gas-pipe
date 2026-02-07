clc, clear
%--------------------------------------------------------------------------
% РОЗПОДІЛ ТИСКУ І ТЕМЕРАТУРИ ПО ДОВЖИНІ ТРУБОПРОВОДУ

% p1 = 101325+3.4*98066.5;   % Pa, тиск газу на вході ПРП2
P0_atm = 66.6; 
p1 = P0_atm*101325;   % Pa, тиск газу на вході
T1 = 273.15+40;   % K, температура газу 
Q1=day2sec(3506);      %m^3/sec (за с.у.)
pEnd_atm = 48.5;
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
[l,y]=ode45(@(u,y) SystRivn_v_2_Danyl(u,y, Q1, 3.57254168),[l0 lf], y0);

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

p_atm = y(:,1) / 101325;
t_c = k2c(y(:,2)); 

% Calculate final pressure and error analysis
p_final_calculated = p_atm(end);  % Last calculated pressure value
p_final_expected = pEnd_atm;      % Expected final pressure

% Calculate errors
absolute_error = p_final_calculated - p_final_expected;
relative_error_percent = (absolute_error / (P0_atm - p_final_expected)) * 100;

% Display results
fprintf('\n=== PRESSURE DROP ANALYSIS ===\n');
fprintf('Initial Pressure (P0):     %.4f atm\n', P0_atm);
fprintf('Expected Final Pressure:   %.4f atm\n', p_final_expected);
fprintf('Calculated Final Pressure: %.4f atm\n', p_final_calculated);
fprintf('Absolute Error:            %.4f atm\n', absolute_error);
fprintf('Relative Error:            %.2f%%\n', relative_error_percent);
fprintf('Expected Pressure Drop:    %.4f atm\n', P0_atm - p_final_expected);
fprintf('Calculated Pressure Drop:  %.4f atm\n', P0_atm - p_final_calculated);
fprintf('===============================\n');

%--------------------------------------------------------------------------
% % РОЗПОДІЛ ТИСКУ І ТЕМЕРАТУРИ ПО ДОВЖИНІ ТРУБОПРОВОДУ
% l0=6150; lf=10000;  % m, початкова і кінцева відстань 
% y0=[px Tx]; % початкові умови
% [l1,y1]=ode45('SystRivn_v_2',[l0 lf],y0);
figure(1), plot(l,p_atm), xlabel('L,м'), ylabel('P, атм'), grid
 figure(2), plot(l,t_c), xlabel('L,м'), ylabel('t, °C'), grid
% figure(3), plot(l,y(:,1),l1,y1(:,1),6150,px,'*'), xlabel('L,м'), ylabel('p,Па'), grid
% figure(4), plot(l,y(:,2),l1,y1(:,2),6150,Tx,'*'), xlabel('L,м'), ylabel('Т,К'), grid

