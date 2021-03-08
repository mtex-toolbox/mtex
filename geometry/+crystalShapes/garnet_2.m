function cS = garnet_2
% complex morphology

%
cs_Grt = crystalSymmetry('m3m');
N = Miller({1,0,0},{1,1,0},{4,3,1},{3,1,1},cs_Grt);
dist = [0.92, 1.02, 3.93, 2.93];
cS = crystalShape(N./dist);