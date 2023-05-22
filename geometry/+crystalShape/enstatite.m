function cS = enstatite
% Orthopyroxene

cs_En = crystalSymmetry('mmm',[18.2406 8.8302 5.1852]);
N = Miller({1,0,0},{0,1,0},{1,1,1},{2,1,0},{2,1,1},{3,1,1},{4,1,0},{1,0,2},cs_En);
dist = [0.6 1 3.3 1.6 3.6 4.12 2.7 5.95];
cS = crystalShape(N./dist);