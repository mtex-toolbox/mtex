function cS = amphibole
% Amphibole

cs_Amp = crystalSymmetry('2/m',[0.544 1 0.295],[90,105,90]*degree);
N = Miller({1,0,0},{0,1,0},{0,0,1},{1,1,0},{0,1,1},{2,0,-1},cs_Amp);
dist = [0.145, 0.05, 0.495, 0.15, 0.5, 0.65];
cS = crystalShape(N./dist);

