function cS = augite
% Clinopyroxene

cs_Aug = crystalSymmetry('2/m',[1.098 1 0.598], [90, 107.6, 90]*degree);
N = Miller({1,0,0},{0,1,0},{0,0,1},{1,1,0},{1,-1,-1},{1,0,-1},cs_Aug);
dist = [0.75, 1.3, 3.1, 1.4, 2.65, 2.6];
cS = crystalShape(N./dist);