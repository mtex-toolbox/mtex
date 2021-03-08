function cS = dolomite

%
cs_Dol = crystalSymmetry('-3',[1 1 0.834]);
N = Miller({0,0,1},{1,0,1},{4,0,1},cs_Dol);
dist = [1.05, 1.2, 2];
cS = crystalShape(N./dist);