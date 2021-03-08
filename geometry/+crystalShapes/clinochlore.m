function cS = clinochlore
 
cs_Clc = crystalSymmetry('2/m',[0.577 1 1.56], [90, 97.08, 90]*degree);
N = Miller({1,0,0},{0,1,0},{0,0,1},{-1,3,0},{2,0,-1},{9,0,-8},{-2,0,7},{-1,0,1},cs_Clc);
dist = [1.26, 0.77, 0.3, 2.5, 2.27, 9.81, 3.4, 1.1];
cS = crystalShape(N./dist);