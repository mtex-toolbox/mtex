function cS = corundum
 
cs_Crn = crystalSymmetry('-32/m',[1 1 2.729]);
N = Miller({0,0,1},{1,0,2},{1,1,3},{2,-1,-1},{1,1,-1},{7,-14,-3},cs_Crn);
dist = [0.5, 1.49, 2.35, 1.53, 9.95, 9.95];
cS = crystalShape(N./dist);