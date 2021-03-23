function cS = calcite

cs_Cal = crystalSymmetry('-32/m',[1 1 0.854]);
N = Miller({1,0,0},{2,-2,1},{-3,2,1},{-2,3,1},{-4,4,1},cs_Cal);
dist = [1.4, 2.6, 4.4, 4.4, 6.35];
cS = crystalShape(N./dist);