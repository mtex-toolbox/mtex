function f = eval(sVF,v)
%
% syntax
%  f = eval(sF,v)
%
% Input
%  v - @vector3d interpolation nodes
%
% Output
%   f - @vector3d
%

M = sVF.sF.eval(v);

[v,~] =  eig3(M(:,1),M(:,2),M(:,4),M(:,3),M(:,5),M(:,6));

f = v(3,:).';

end
