function SO3F = regularize(nodes,y,lambda,varargin)
% computes a regularization
%
% Syntax
%   SO3F = SO3FunHarmonic.regularize(SO3Grid,f,lambda)
%   SO3F = SO3FunHarmonic.regularize(SO3Grid,f,lambda,'bandwidth',
%        bandwidth,'weights',W,'fourier_weights',What)
%
% Input
%  SO3Grid - grid on the rotation group
%  f      - function values on the grid (may be multidimensional)
%  lambda - parameter for regularization
%
% Output
%  SO3F - @SO3FunHarmonic
%
% Options
%  bandwidth  - maximum harmonic degree
%  W          - weight w_n for the node nodes (default: equal/Voronoi weights)
%  What       - weight what_{n}^{k,l} for the Fourier space (default Sobolev weights for s = 2)
%
% See also
% SO3FunHarmonic.interpolate

SO3F = SO3FunHarmonic.interpolate(nodes,y,'regularization',lambda,varargin{:});
