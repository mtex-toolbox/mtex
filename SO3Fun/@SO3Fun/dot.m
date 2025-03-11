function val = dot(SO3F1,SO3F2,varargin)
% inner product between two SO3Fun
%
% $$ dot(f_1,f_2) = \sqrt{\frac1{8\pi^2} \int_{SO(3)} f_1(R) f_2(R) dR$$,
%
% Syntax
%   d = dot(SO3F1,SO3F2)
% 
% Input
%  SO3F1, SO3F2 - @SO3Fun
%
% Output
%  t - double
%

val = cor(SO3F1,SO3F2,varargin{:});