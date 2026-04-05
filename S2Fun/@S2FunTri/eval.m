function f =  eval(sF,v)
% evaluates the spherical function at nodes v
%
% Syntax
%   f = eval(sF,v)
%
% Input
%  sF - @S2FunTri
%  v - interpolation nodes @vector3d
%
% Output
%  f - function values
%

bario = calcBario(sF.tri,v(~v.isnan));

f = nan(numel(v),numel(sF));

f(~v.isnan,:) = bario * sF.values;

end
