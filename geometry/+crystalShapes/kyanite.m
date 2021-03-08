function cS = kyanite

%
cs_Ky = crystalSymmetry('-1',[0.907 1 0.71], [90, 101.2, 106]*degree);
N = Miller({1,0,0},{0,1,0},{0,0,1},{1,-1,0},{1,1,0},cs_Ky);
dist = [0.4, 1, 2.4, 1.05, 1.2];
cS = crystalShape(N./dist);