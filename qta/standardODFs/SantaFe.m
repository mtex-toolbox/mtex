function odf = SantaFe
% the SantaFe-sample ODF

CS = symmetry('cubic');
SS = symmetry('222');

psi = kernel('von Mises Fisher','HALFWIDTH',10*degree);
g0 = Miller2quat(Miller(1,2,2,CS),Miller(2,2,1,CS));

odf =  0.73 * uniformODF(CS,SS,'comment','the SantaFe-sample ODF') ...
  + 0.27 * unimodalODF(g0,CS,SS,psi);


% 3,7
% SANTA FE
% 3,1,0
% 0.73
% 63.435,48.190,63.435
% 1,20.0,0.27,1
%q = euler2quat(63.435*degree,48.190*degree,63.435*degree,'BUNGE');
