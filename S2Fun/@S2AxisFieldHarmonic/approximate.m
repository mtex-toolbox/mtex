function sAF = approximate(f, varargin)
% computes an approximation from a given spherical axis field by computing 
% the spherical Fourier coefficients with quadrature componentwise.
%
% Syntax
%   sAF = S2AxisFieldHarmonic.approximate(f)
%   sAF = S2AxisFieldHarmonic.approximate(f, 'bandwidth', bw)
%
% Input
%  f - function handle in @vector3d
%
% Output
%  sAF - @S2AxisFieldHarmonic
%
% Options
%  bw - degree of the spherical harmonic (default: 128)
%
% See also
% S2AxisFieldHarmonic/quadrature S2AxisFieldHarmonic

sAF = S2AxisFieldHarmonic.quadrature(f,varargin{:});

end
