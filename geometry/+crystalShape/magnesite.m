function cS = magnesite

%
cs_Mgs = crystalSymmetry('-32/m',[1 1 0.81]);
N = Miller({1,0,0},{0,0,1},{1,0,1},{2,-1,0},cs_Mgs);
dist = [1.25, 0.9, 1, 1.94];
cS = crystalShape(N./dist);