function cS = epidote

cs_Ep = crystalSymmetry('2/m',[1.591 1 1.812], [90, 115.4, 90]*degree);
N = Miller({1,0,0},{0,0,1},{1,0,-1},{1,-1,1},{1,-1,-1},cs_Ep);
dist = [0.6, 0.6, 0.6, 3, 2.4];
cS = crystalShape(N./dist);