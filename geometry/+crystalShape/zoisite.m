function cS = zoisite

%
cs_Zo = crystalSymmetry('mmm',[2.916 1 1.805]);
N = Miller({1,0,0},{1,0,1},{1,0,2},{1,1,1},{2,1,0},{3,1,1},cs_Zo);
dist = [0.9, 1.05, 1.4, 3.9, 4.2, 4.75];
cS = crystalShape(N./dist);