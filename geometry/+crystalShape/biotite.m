function cS =  biotite
% Mica
 
cs_Bt = crystalSymmetry('2/m',[0.577 1 1.105], [90, 100.2, 90]*degree);
N = Miller({0,0,1},{0,1,0},{3,3,1},cs_Bt);
dist = [0.2, 1, 5];
cS = crystalShape(N./dist);