function t = textureindex(odf,varargin)
% caclulate texture index of ODF
%
% The tetxure index of an ODF f is defined as:
%
% $$ t = \int_{SO(3)} |f(R)|^2 dR $$,
%
% where $vol(SO(3)) = \int_{SO(3)} 1 dR = 8\pi^2$.
%
% Input
%  odf - @SO3Fun
%
% Output
%  texture index - double
%
% Options
%  resolution - resolution of the discretization
%
% See also
% SO3Fun/norm SO3Fun/entropy SO3Fun/volume SO3Fun/SO3Fun SO3Fun/calcFourier

warning('The command textureindex is depreciated! Please use squared norm instead.')

t = norm(odf,varargin{:}).^2;
