function cS = titanite
% sphene

%
cs_Ttn = crystalSymmetry('2/m',[0.753 1 0.854], [90, 119.72, 90]*degree);
N = Miller({0,1,0},{0,0,1},{1,1,1},{0,1,1},cs_Ttn);
dist = [0.89, 1.39, 1, 1.4];
cS = crystalShape(N./dist);