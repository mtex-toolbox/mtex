function SO3F = quadrature(f, varargin)
% Compute the kernel density coefficients of a given @SO3Fun or
% given evaluations on a specific approximation grid.
%
% This method calls SO3FunRBF/approximation, and exists only to have an 
% equivalent function name to SO3FunHarmonic/quadrature
%
% Syntax
%   SO3F = SO3FunRBF.quadrature(nodes,values)
%   SO3F = SO3FunRBF.quadrature(f)
%   SO3F = SO3FunRBF.quadrature(f, 'bandwidth', bandwidth)
%   SO3F = SO3FunRBF.quadrature(f, 'kernel', psi)
%
% Input
%  f  - @SO3Grid, @rotation, @orientation
%  values - double (first dimension has to be the evaluations)
%  f - function handle in @orientation (first dimension has to be the evaluations)
%
% Output
%  SO3F - @SO3FunRBF
%
% Options
%  bandwidth      - minimal harmonic degree (default: 64)
%
% See also
% SO3FunRBF/approximation, SO3FunHarmonic/quadrature

SO3F = SO3FunRBF.approximation(f,varargin{:});

