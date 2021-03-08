function cS = topaz

%
cs_Tpz= crystalSymmetry('mmm',[0.529 1 0.955]);
N = Miller({0,0,1},{1,1,0},{1,2,0},{1,0,1},{1,1,1},{1,2,1},{0,2,1},{1,1,3},{1,1,2},{0,2,3},cs_Tpz);
dist = [0.8, 0.85, 1.25, 1.18, 1.25, 1.7, 1.45, 2.735, 1.95, 3.02];
cS = crystalShape(N./dist);