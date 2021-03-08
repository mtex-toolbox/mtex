function cS = garnet_1
% simple morphology
%

cs_Grt = crystalSymmetry('m3m');
N= Miller({1,0,0},{2,1,1},cs_Grt);
dist = [0.45, 1];
cS = crystalShape(N./dist);