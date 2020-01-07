function f = eval(SO3VF,v,varargin)
%
% syntax
%   f = eval(SO3VF,v)
%
% Input
%   v - @vector3d interpolation nodes
%
% Output
%   f - @vector3d
%

f = vector3d(SO3VF.SO3F.eval(v)');
f = reshape(f',size(v));

end
