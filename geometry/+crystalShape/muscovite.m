function cS = muscovite
% Mica

%
cs_Ms = crystalSymmetry('2/m',[0.574 1 2.222], [90, 95.5, 90]*degree);
N = Miller({0,1,0},{0,0,1},{1,-1,0},{1,1,-1},{-5,-15,1},cs_Ms);
dist = [0.9, 0.13, 2.15, 2.2, 18];
cS = crystalShape(N./dist);