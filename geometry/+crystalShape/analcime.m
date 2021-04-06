function cS = analcime
%

cs_Anl = crystalSymmetry('m3m');
N = Miller({1,0,0},{2,1,1},{1,1,1},cs_Anl);
dist = [0.45, 1, 0.735];
cS = crystalShape(N./dist);