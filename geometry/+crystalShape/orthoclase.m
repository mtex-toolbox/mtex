function cS = orthoclase
% K-feldspar

%
cs_Or = crystalSymmetry('2/m',[0.661 1 0.556], [90, 116.07, 90]*degree);
N= Miller({0,1,0},{0,0,1},{1,-1,0},{1,-1,-1},{2,0,-1},cs_Or);
dist = [0.5, 1.4, 0.6, 1.75, 1.3];
cS = crystalShape(N./dist);