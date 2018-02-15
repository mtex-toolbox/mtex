function f =  eval(sF,v)
%
% syntax
%  f = eval(sF,v)
%
% Input
%  v - interpolation nodes
%
% Output
%

bario = calcBario(sF.tri,v);

f = bario * sF.values(:);

end




