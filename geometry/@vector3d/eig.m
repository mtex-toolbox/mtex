function [lambda,v] = eig(v,varargin)
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

M = [v.x v.y v.z]'*[v.x v.y v.z];
[v, lambda] = eig3(M);
lambda = lambda/length(v);

% for some reason Matlab eig function changes to order outputs if called
% with two arguments - so we should do the same
[lambda,v] = deal(v,lambda);