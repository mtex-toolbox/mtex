function cS = aragonite

cs_Arg = crystalSymmetry('mmm',[0.622 1 0.721]);
N = Miller({0,1,0},{1,1,1},{1,2,1},{1,2,2},{0,1,1},{1,1,0},cs_Arg);
dist = [1.5, 6.69, 7.94, 11.32, 4.82, 3.5];
cS = crystalShape(N./dist);