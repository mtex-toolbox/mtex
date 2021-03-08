function cS = staurolite

%
cs_St = crystalSymmetry('2/m',[0.469 1 0.34], [90, 90, 90]*degree);
N = Miller({1,0,0},{0,1,0},{0,0,1},{1,1,0},{2,0,1},{2,0,-1},cs_St);
dist = [2.43, 1.3, 6.5, 2.45, 9.85, 9.85];
cS = crystalShape(N./dist);