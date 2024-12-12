function c = crossCor(SO3F1,SO3F2)
% cross correlation between two SO3Funs
%
% $$ CC(f_1,f_2) = \sqrt{\frac1{8\pi^2} \int_{SO(3)} f_1(R) f_2(R) dR$$,
%
% Syntax
%   c = crossCor(SO3F1,SO3F2)
% 
% Input
%  SO3F1, SO3F2 - @SO3Fun
%
% Output
%  c - @SO3Fun
%

c = conv(SO3F2.conj,SO3F1.inv);

end