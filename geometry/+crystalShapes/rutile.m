function cS = rutile

%
cs_Rt = crystalSymmetry('4/mmm',[1 1 0.644]);
N = Miller({1,0,0},{1,1,0},{1,0,1},cs_Rt);
dist= [0.35, 0.5, 1];
cS = crystalShape(N./dist);