function cS = chromite
 
cs_Chr = crystalSymmetry('m3m');
N = Miller({1,1,0},cs_Chr);
dist = 1;
cS = crystalShape(N./dist);