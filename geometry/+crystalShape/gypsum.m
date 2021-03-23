function cS = gypsum

%
cs_Gp = crystalSymmetry('2/m',[0.43 1 0.414], [90, 127.4, 90]*degree);
N = Miller({0,1,0},{0,1,1},{1,2,0},cs_Gp);
dist = [0.16, 0.75, 0.8];
cS = crystalShape(N./dist);