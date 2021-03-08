function cS = forsterite
% Olivine

cs_Fo = crystalSymmetry('mmm',[0.466 1 0.586]);
N = Miller({0,1,0},{0,0,1},{0,2,1},{1,1,0},{1,0,1},{1,2,0},cs_Fo);
dist = [0.4, 1.3, 1.4, 1.05, 1.85, 1.35];
cS = crystalShape(N./dist);