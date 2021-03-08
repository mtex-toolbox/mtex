function cS = quartz
%
cs_Qz = crystalSymmetry('32',[1 1 1.1]);
N = Miller({1,0,0},{1,0,1},{0,1,1},{1,-2,1},{6,-1,1},{5,-6,-1},cs_Qz);
dist = [0.45, 0.85, 0.96, 1.23, 2.96, 2.87];
cS = crystalShape(N./dist);