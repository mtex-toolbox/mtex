function cS = magnetite

%
cs_Mag = crystalSymmetry('m3m');
N = Miller({1,0,0},{1,1,1},cs_Mag);
dist = [0.95, 1];
cS = crystalShape(N./dist);