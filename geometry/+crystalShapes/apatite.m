function cS = apatite
 
cs_Ap = crystalSymmetry('6/m',[1 1 0.734]);
N = Miller({1,0,0},{0,0,1},{1,0,1},{2,-1,0},{2,-1,1},cs_Ap);
dist = [1, 1.65, 2.25, 1.9, 3];
cS = crystalShape(N./dist);