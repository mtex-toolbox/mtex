function SO3F = interpolate(nodes,y,varargin)
% Approximate BinghamODF from individual orientations via kernel density 
% estimation
%
% Syntax
%   SO3F = SO3FunBingham.interpolate(nodes, y)
%
% Input
%  nodes - rotational grid @SO3Grid, @orientation, @rotation
%  y     - function values on the grid (maybe empty)
%
% Output
%  SO3F - @SO3FunBingham
%
% See also
% calcBinghamODF rotation/interp

if isnumeric(nodes) && nargin==1
  y=[];
end

SO3F = calcBinghamODF(nodes,'weights',y);
