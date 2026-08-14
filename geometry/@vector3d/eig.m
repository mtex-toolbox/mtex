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

xyz = v.xyz;
% carry the frame and the private convention, not the resolved one -
% that would pin a merely inherited frame or default onto the result
fr = v.frame; pC = v.how2plotPrivate;
[v, lambda] = eig3(xyz.' * xyz);
v.frame = fr; v.how2plotPrivate = pC;

% for some reason Matlab eig function changes to order outputs if called
% with two arguments - so we should do the same
[lambda,v] = deal(v,lambda);