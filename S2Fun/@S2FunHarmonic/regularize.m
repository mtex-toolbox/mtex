function sF = regularize(nodes,y,lambda,varargin)
% computes a regularization
%
% Syntax
%   sF = S2FunHarmonic.regularize(S2Grid,f,lambda)
%   sF = S2FunHarmonic.regularize(S2Grid,f,lambda,'bandwidth',
%        bandwidth,'weights',W,'fourier_weights',What)
%
% Input
%  S2Grid - grid on the sphere
%  f      - function values on the grid (may be multidimensional)
%  lambda - parameter for regularization
%
% Output
%  sF - @S2FunHarmonic
%
% Options
%  bandwidth  - maximum harmonic degree
%  W          - weight w_n for the node nodes (default: Voronoi weights)
%  What       - weight what_{m,l} for the Fourier space (default Sobolev weights for s = 2)
%
% See also
% S2FunHarmonic.interpolate

sF = S2FunHarmonic.interpolate(nodes,y,'regularization',lambda,varargin{:});
