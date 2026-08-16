function cS = albite
% Albite (Plagioclase feldspar)
%

cs_Ab= crystalSymmetry('-1',[0.636 1 0.559],[94.33,116.56,87.65]*degree);

N= Miller({1,0,0},{0,1,0},{0,0,1},{1,1,0},{-1,1,1},{-1,1,0},{1,1,-1},cs_Ab);

dist= [5.5, 1.6, 6.5, 5.9, 9.3, 5.65, 8];

cS = crystalShape(N./dist);

end

