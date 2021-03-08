function cS = brucite
 
cs_Brc = crystalSymmetry('-32/m',[1 1 1.502]);
N = Miller({0,0,1},{1,0,1},{2,0,1},{1,1,1},{-2,2,1},{0,-1,1},{0,2,1},cs_Brc);
dist = [0.39, 1.23, 2.5, 2.8, 2.5, 1.25, 5];
cS = crystalShape(N./dist);