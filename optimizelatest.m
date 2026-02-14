clc; clear; close all;

P0 = [66.6; 66.5; 66.4; 66.2; 66.1];


Q = [3506; 3492; 3484; 3479; 3459];


Pk = [48.5; 48.3; 48.3; 48.2; 48.0];



opts_ode = odeset('RelTol',1e-7,'AbsTol',1e-9);
opts_opt = optimoptions('lsqnonlin','Display','iter','FunctionTolerance',1e-10,'StepTolerance',1e-10,'OptimalityTolerance',1e-10);
a0 = 3.5356354124;
a = lsqnonlin(@(a) R(a, P0, Q, Pk), a0, 3,4, opts_opt);

fprintf('===============================\n');
fprintf('Optimized a:     %.10f', a);

function r = R(lyam, pInp, Qv, pEnd)

percentErrorArr = 1:numel(pInp);
pEi = 1;
for i=1:numel(pInp)
    percentErrorArr(pEi) = calcBaseFunc(lyam, pInp(i), Qv(i), pEnd(i));
    pEi = pEi + 1;
end

r = 0 - trapz(percentErrorArr);

end