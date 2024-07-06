function H = entropy(SO3F,varargin)
% calculate entropy of SO3Fun
%
% The entropy of a SO3Fun f is defined as:
%
% $$ e = - \int_{SO(3)} f(R) \ln f(R) dR$$
%
% Syntax
%   e = entropy(SO3F)
%
% Input
%  SO3F - @SO3Fun 
%
% Output
%  e - double
%
% Options
%  resolution - resolution of the discretization
%
% See also
% SO3Fun/norm SO3Fun/sum


% TODO: nur einmal f auswerten und integrand nicht in SO3FunHarmonic umwandeln.

H = mean(- SO3F.*log(SO3F));


end