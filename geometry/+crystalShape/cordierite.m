function cS = cordierite
 
cs_Crd = crystalSymmetry('mmm',[0.568 1 0.549]);
N = Miller({1,0,0},{0,1,0},{0,0,1},{1,1,0},{1,1,1},{1,3,0},{1,1,2},{0,1,1},cs_Crd);
dist = [2.1, 1.05, 3.5, 2.25, 5.3, 3.65, 8.7, 4.45];
cS = crystalShape(N./dist);