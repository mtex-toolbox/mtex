function odf = mix2
% mix2 sample ODF

CS = crystalSymmetry('cubic');
SS = specimenSymmetry('222');

odf(1) = 0.3095*uniformODF(CS,SS);

psi = kernel('von Mieses Fischer','HALFWIDTH',17*degree);
q1 = euler2quat(54.736*degree, 45.0*degree, 0.0*degree);
odf(2) = 0.315*ODF(q1,1,psi,CS,SS);

q2 = euler2quat(62.968*degree, 57.689*degree, 71.565*degree);
odf(3) = 0.315*ODF(q2,1,psi,CS,SS);

q3 = euler2quat(50.768*degree, 65.905*degree, 63.435*degree);
odf(4) = 0.0605*ODF(q3,1,psi,CS,SS);


% 3,7
% MIX2
% 3,3,0
% 0.3095
% 54.736,45.0,0.0
% 1,17.0,0.315,2
% 62.968,57.689,71.565
% 1,17.0,0.315,2
% 50.768,65.905,63.435
% 1,17.0,0.0605,1
