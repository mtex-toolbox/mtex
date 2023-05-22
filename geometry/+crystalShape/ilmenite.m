function cS = ilmenite

%
cs_Ilm = crystalSymmetry('-3',[1 1 2.768]);
N = Miller({1,0,0},{0,0,1},{1,0,2},{2,-1,3},cs_Ilm);
dist = [1.1, 0.2, 1, 1.8];
cS = crystalShape(N./dist);