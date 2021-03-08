function cS = antigorite
% serpentine

cs_Atg = crystalSymmetry('m',[4.7013 1 0.7844], [90, 91.633, 90]*degree);
N = Miller({0,0,1},{0,0,-1},{1,0,0},{-1,0,0},{2,1,0},{-2,1,0},cs_Atg);
dist = [0.15, 0.15, 0.4, 0.4, 2, 2];
cS = crystalShape(N./dist);