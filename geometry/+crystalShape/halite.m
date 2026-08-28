function cS = halite

%
cs_Hl = crystalFrame('m3m');
N = Miller({1,0,0},cs_Hl);
dist= 1;
cS = crystalShape(N./dist);