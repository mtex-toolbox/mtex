function cS = diamond
 
cs_Dia = crystalSymmetry('m3m');
N = Miller({1,1,1},{1,1,0},cs_Dia);
dist = [1.05, 1.01];
cS = crystalShape(N./dist);