function yp=Rozrax_Cp_Func(u,p, Q, ro, tempGasStart, k) % p - Pa
% x = [ Metan   Etan   Propan  n-Butan  i-Butan  Azot  CO2  H2S ]
  x = [ 93.635  3.075  0.881   0.141    0.170   1.181  0.917  0]/100;  
 % Ro_st = 0.7186  
Qc=Q; % m^3/s
Roc = ro; % kg/m3
qm=Qc*Roc; % kg/s
g=9.81;
dely=0; % m - pipe angle delta
L=122000;
Dv=1.3880; %m

pm = p/1e6;  % MPa
T = c2k_func(tempGasStart); % K
[~,~,Mm] = Cp_Vnic_func(pm,T,x);  %  [ kDg/(kg*K), kg/m3, kg/kmol ]
xa = x(6)/100; xy = x(7)/100;

[~,z,~]=FGerg91Func(pm,T,xa,xy,Roc);
mu=1.8e-05; % methan gas Pa * S for temp 293 K
%Re = (4 * ro * Q) / (pi * Dv * mu);

F=(pi*Dv.^2)/4;  % Ploshca poperechnogo peretinu truboprovodu, m2
R=8314.472;      % Gazova stala,   Dg/(kMol*K)

Re = 4*qm/(pi*(mu)*Dv);

%k0 = 0.316;

%k0 = 0.7;
 
lyam = 0.316/(Re).^(1/4) * k; %koeficient gidravlichnogo opory


yp=-((Mm*g*dely*p)/(z*T*R*L)+(qm.^2*lyam*z*R*T)/(2*Dv*F.^2*Mm*p));

