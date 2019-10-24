function r = ldivide(a,b)
% o .\ v 
%
% Syntax
%   h = o .\ r
%
% Input
%  o - @orientation
%  r - @vector3d
%
% Output
%  h - @Miller indice
%
% See also
% 

r = inv(a) .* b;
