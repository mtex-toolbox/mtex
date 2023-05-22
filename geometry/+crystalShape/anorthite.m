function cS = anorthite
% (Plagioclase feldspar)

cs_An = crystalSymmetry('-1',[8.1797 12.8748 14.1721], [93.13,115.89,91.24]*degree);
N = Miller({0,1,0},{0,0,1},{1,1,0},{1,-1,0},{1,1,-1},{1,-1,-1},{2,0,-1},cs_An);
dist = [0.65, 0.5, 1.25, 1.2, 1.2, 1.05, 0.95];
cS = crystalShape(N./dist);