function cS = tourmaline_1
% simple morphology
%
cs_Tur = crystalSymmetry('3m',[1 1 0.452]);
N = Miller({1,-1,0},{1,-2,0},{0,-1,-1},{2,-2,1},{-1,1,1},cs_Tur);
dist = [0.23, 0.44, 1, 1.145, 0.9];
cS = crystalShape(N./dist);