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

SO3F = - SO3F.*log(SO3F);

nodes = equispacedSO3Grid(SO3F.SRight,SO3F.SLeft,'resolution',2.5*degree,varargin{:});
values = SO3F.eval(nodes(:));
H = sum(values,'omitnan')/length(values);

end