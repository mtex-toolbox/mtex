function v = mean(SO3VF,varargin)
%
% Syntax
%   f = mean(SO3VF)
%
% Output
%   v - @vector3d
%

res = get_option(varargin,'resolution',2.5*degree);
nodes = equispacedSO3Grid(SO3VF.SRight,SO3VF.SLeft,'resolution',res);
v = mean(SO3VF.eval(nodes(:)));

end