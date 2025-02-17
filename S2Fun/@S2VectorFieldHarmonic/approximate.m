function sVF = approximate(f, varargin)
% computes an approximation from a given spherical vector field by computing 
% the spherical Fourier coefficients with quadrature componentwise.
%
% Syntax
%   sVF = S2VectorField.approximate(f)
%   sVF = S2VectorField.approximate(f, 'bandwidth', bw)
%
% Input
%   f - @S2VectorField, @function_handle in vector3d
%
% Output
%   sVF - @S2VectorFieldHarmonic
%
% Options
%   bw - degree of the spherical harmonic (default: 128)
%
% See also
% S2VectorFieldHarmonic/quadrature S2VectorFieldHarmonic

sVF = S2VectorFieldHarmonic.quadrature(f,varargin{:});

end
