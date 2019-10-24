function v = setdiff(v1,v2,varargin)
% remove vectors v2 from a set of vectors v1
%
% Syntax
%   v = setdiff(v1,v2)
%   v = setdiff(v1,v2,'antipodal')
%
% Input
%  v1, v2 - @vector3d
%
% Output
%  v - vector3d
%
% Options
%  antipodal - include antipodal symmetry
%


isEqu = isnull(dot_outer(v1,v2,varargin{:}) - reshape(sqrt(dot(v1,v1)),[],1) * reshape(sqrt(dot(v2,v2)),1,[]),1e-3);


v = v1.subSet(~any(isEqu,2));

