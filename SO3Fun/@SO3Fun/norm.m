function t = norm(SO3F,varargin)
% caclulate texture index of SO3Fun
%
% The norm of an SO3Fun f is defined as:
%
% $$ t = \sqrt(-\int f(g)^2 dg)$$
%
% Input
%  SO3F - @SO3Fun 
%
% Output
%  texture index - double
%
% Options
%  bandwidth  - bandwidth used for Fourier calculation
%
% See also
% ODF/textureindex ODF/entropy ODF/volume ODF/ODF ODF/calcFourier

t = sqrt(mean(SO3F.^2));
    
end
