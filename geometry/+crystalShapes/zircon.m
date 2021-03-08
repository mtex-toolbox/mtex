function cS = zircon

%
cs_Zrn = crystalSymmetry('4/mmm',[1 1 0.905]);
N = Miller({1,0,0},{1,0,1},{1,1,2},{1,1,0},{2,1,1},{0,0,1},cs_Zrn);
dist = [2.15, 5.7, 10.9, 2.8, 8.4, 5.3];
cS = crystalShape(N./dist);