function cS = spinel

%
cs_Spl= crystalSymmetry('m3m');
N = Miller({1,1,0},{1,1,1},cs_Spl);
dist = [0.99, 1];
cS = crystalShape(N./dist);