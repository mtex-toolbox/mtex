function odf = mix2
% mix2 sample ODF

CS = crystalSymmetry('cubic');
SS = specimenSymmetry('222');

psi = vonMisesFisherKernel(HALFWIDTH',17*degree);
ori1 = orientation.byEuler(54.736*degree, 45.0*degree, 0.0*degree,CS,SS);
ori2 = orientation.byEuler(62.968*degree, 57.689*degree, 71.565*degree,CS,SS);
ori3 = orientation.byEuler(50.768*degree, 65.905*degree, 63.435*degree,CS,SS);

odf = 0.3095*uniformODF(CS,SS) + 0.315*unimodalODF(ori1,psi) + ...
  0.315*unimodalODF(ori2,psi) + 0.0605*uniformODF(ori3,psi);


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
