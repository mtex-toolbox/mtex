function cS = andalusite

cs_And = crystalSymmetry('mmm',[0.987 1 0.703]);
N = Miller({1,0,0},{0,1,0},{0,0,1},{1,1,0},{2,1,0},{1,2,1},{0,1,1},cs_And);
dist = [1.02, 1, 2.55, 1.15, 2.09, 4.2, 3.1];
cS = crystalShape(N./dist);