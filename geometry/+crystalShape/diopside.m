function cS = diopside
% Clinopyroxene
 
cs_Di = crystalSymmetry('2/m',[9.746 8.99 5.251], [90, 105.63, 90]*degree);
N = Miller({1,0,0},{0,1,0},{0,0,1},{1,1,0},{1,0,-1},{2,2,-1},{3,1,0},cs_Di);
dist = [1.1, 2.1, 6, 2.5, 6.75, 8.3, 4.2];
cS = crystalShape(N./dist);