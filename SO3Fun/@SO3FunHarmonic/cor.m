function val = cor(SO3F1,SO3F2)
% correlation between two two SO3Fun
%
% $$ cor(f_1,f_2) = \sqrt{\frac1{8\pi^2} \int_{SO(3)} f_1(R) f_2(R) dR$$,
%
% Syntax
%   c = cor(SO3F1,SO3F2)
% 
% Input
%  SO3F1, SO3F2 - @SO3FunHarmonic
%
% Output
%  t - double
%

s = size(SO3F2);
bw = min(SO3F1.bandwidth,SO3F1.bandwidth);
SO3F1.bandwidth = bw;
SO3F2.bandwidth = bw;

SO3F1 = SO3F1.subSet(':');
SO3F2 = SO3F2.subSet(':');

val = SO3F1.fhat.' * conj(SO3F2.fhat) ;

val = reshape(val,s);

if SO3F1.isReal && SO3F2.isReal, val = real(val); end


end
