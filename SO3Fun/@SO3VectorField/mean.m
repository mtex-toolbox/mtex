function v = mean(SO3VF,varargin)
% mean of a vector field on SO(3)
%
% The vector field is averaged over an equispaced grid of orientations.
%
% Syntax
%
%   v = mean(SO3VF)                            % over a grid of resolution 2.5 degree
%   v = mean(SO3VF,'resolution',1*degree)      % over a finer grid
%
% Input
%  SO3VF - @SO3VectorField
%
% Output
%  v - @vector3d
%
% Options
%  resolution - resolution of the grid, default 2.5*degree

res = get_option(varargin,'resolution',2.5*degree);
nodes = equispacedSO3Grid(SO3VF.SRight,SO3VF.SLeft,'resolution',res);
v = mean(vector3d(SO3VF.eval(nodes(:))));



end