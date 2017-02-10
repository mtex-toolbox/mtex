function t = trace(sS,n,varargin)
% trace of the slip plane in the surface normal to n
%
% Syntax
%
%   t = trace(sS) % trace in the xy surface
%   t = trace(sS,n) % trace in the surface normal to n
%
% Input
%  sS - list of @slipSystem
%  n  - @vector3d normal vector 
%
% Output
%  t - @vector3d 

if nargin == 1, n = vector3d.Z; end
t = normalize(cross(sS.n,n));
t.antipodal = true;
