function t = textureindex(odf,varargin)
% caclulate texture index of ODF
%
% The tetxure index of an ODF f is defined as:
%
% $$ t = \int f(g)^2 dg$$
%
% Input
%  odf - @ODF 
%
% Output
%  texture index - double
%
% Options
%  resolution - resolution of the discretization
%  fourier    - use Fourier coefficients 
%  bandwidth  - bandwidth used for Fourier calculation
%
% See also
% ODF/norm ODF/entropy ODF/volume ODF/ODF ODF/calcFourier

t = norm(odf,varargin{:}).^2;
