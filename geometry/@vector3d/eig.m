function [lambda,ev] = eig(v,varargin)
% eigenvalues and eigenvectors for a list of @vector3d
%
% Syntax
%
%   lambda = eig(v)
%
%   [lambda,v] = eig(v)
%
% Input
%  v        - @vector3d
%
% Output
%  lambda   - eigen values
%  v        - eigen vectors
%

xyz = v.xyz;
[ev, lambda] = eig3(xyz.' * xyz);
ev.refSystem = v.refSystem;

% for some reason Matlab eig function changes to order outputs if called
% with two arguments - so we should do the same
[lambda,ev] = deal(ev,lambda);