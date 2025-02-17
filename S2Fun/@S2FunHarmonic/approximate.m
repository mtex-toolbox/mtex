function sF = approximate(f, varargin)
% computes an approximation from a given spherical function by computing 
% the spherical Fourier coefficients with quadrature
%
% Syntax
%   sF = S2FunHarmonic.approximate(f)
%   sF = S2FunHarmonic.approximate(f, 'bandwidth', bandwidth)
%
% Input
%  f      - function on the sphere (may be multidimensional)
%
% Options
%  bandwidth  - maximum degree of the spherical harmonics used to approximate the function
%
% See also
% S2FunHarmonic/quadrature S2FunHarmonic

sF = S2FunHarmonic.quadrature(f,varargin{:});

end
