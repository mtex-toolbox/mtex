function odf = SantaFe
% the SantaFe-sample ODF

CS = crystalSymmetry('cubic');
SS = specimenSymmetry('222');

psi = vonMisesFisherKernel('HALFWIDTH',10*degree);
ori = orientation.byMiller(Miller(1,2,2,CS),Miller(2,2,1,CS),CS,SS);

odf =  0.73 * uniformODF(CS,SS) + 0.27 * unimodalODF(ori,CS,SS,psi);


% 3,7
% SANTA FE
% 3,1,0
% 0.73
% 63.435,48.190,63.435
% 1,20.0,0.27,1
%q = rotation.byEuler(63.435*degree,48.190*degree,63.435*degree,'BUNGE');
