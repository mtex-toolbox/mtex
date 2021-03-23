function cS = microcline
% K-feldspar

cs_Mc = crystalSymmetry('2/m',[0.661 1 0.556], [90, 116.07, 90]*degree);
N = Miller({0,1,0},{0,0,1},{0,1,1},{1,0,-1},{1,1,0},{1,-1,-1},{2,0,-1},{1,-3,0},cs_Mc);
dist = [0.22, 0.95, 1.12, 1.7, 1.82, 1.75, 2.9, 1.93];
cS = crystalShape(N./dist);