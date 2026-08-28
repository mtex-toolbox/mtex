function cS = fluorite
% simple morphology
%
cs_Fl= crystalFrame('m3m');
N= Miller({1,1,1},cs_Fl);
dist= 1;
cS = crystalShape(N./dist);