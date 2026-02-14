function yp=SystRivn_v_2_Danyl_Func(l,y, Q, k)
% x = [ Metan   Etan   Propan  n-Butan  i-Butan  Azot  CO2  H2S ]
  x = [ 93.635  3.075  0.881   0.141    0.170   1.181  0.917  0]/100;

Roc = 0.682;     % kg/m^3
g = 9.81;         % m/c^2
R = 8314.472;     % Dg/(kMol*K)

  Qc = Q;    % m^3/s
  qm = Qc*Roc;    % kg/s
L=122000;        % m
Dvn=1.388;      % m
Dz=1.428;       % m
% Dvn = 0.300;      % m
% Dz = 0.330;       % m
% L = 5000;         % m
dely = 0;         % m

   
  p1=y(1);      % Pa
  p=p1/1e6;     % MPa
  T=y(2);       % K

[Cp_kg,Ro,Mm] = Cp_Vnic_func(p,T,x);     % [ kDg/(kg*K), kg/m3, kg/kmol ]
Cp_kg = Cp_kg*1000;                 % Dg/(kg*K)
xa = x(6); xy = x(7);
Kjt = met_nulp_func(p,T,xa,xy,Roc);     % K/MPa
Kjt = Kjt / 1e6;                    % K/Pa
Mj=VisG1Func(p,T,xa,xy,Roc);            % mkPa*s
[Kgerg,z,zc]=FGerg91Func(p,T,xa,xy,Roc);

kt=1.75;          % Vt/(m2*K)

  Rsh=0.0002;     % m
  Re = 4*qm/(pi*(Mj*1e-6)*Dvn);
  C2 = 0.26954;
  kD = C2*Rsh/Dvn;
  kR = 5.035/Re;
  %lyamda = (1.74-2*log10(2*Rsh/Dvn-k*log10(kD - kR*log10(kD+3.3333*kR))/Re))^(-2);%standart 
  
  %lyamda = 0.316/(Re).^(1/4) * k; % blasius
  k = 3.536;
  lyamda = (0.79*log(Re) - k)^(-2);
  %lyamda = 0.0092269839;
  
Tgr = 293.15; % K
  
dp_dx = -(((Mm*g*dely.*p1^2)./(z*R*T*L)+(8*lyamda*qm^2*z*R.*T)./...
    (Mm*pi^2*Dvn^5))/(p1-(16*qm^2*z*R.*T)/(Mm*pi^2*Dvn^4.*p1))); 
dT_dx = -((kt*pi*Dz)/(qm*Cp_kg).*(T-Tgr)-(Kjt+(16*qm^2*z^2*R^2.*T^2)./...
    (Cp_kg*Mm^2*pi^2*Dvn^4.*p1^3)).*dp_dx+(g*dely)/(Cp_kg*L));

 yp=[dp_dx;dT_dx];


  

