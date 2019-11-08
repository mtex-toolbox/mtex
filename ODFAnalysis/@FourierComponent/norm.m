function t = norm(component,varargin)
% caclulate texture index of ODF
%
% The norm of an ODF f is defined as:
%
% $$ t = -\int f(g)^2 dg$$
%
% Input
%  odf - @ODF 
%
% Output
%  texture index - double
%
% See also
% ODF/textureindex ODF/entropy ODF/volume ODF/ODF ODF/calcFourier

t = norm(Fourier(component,'l2-normalization',varargin{:}));
