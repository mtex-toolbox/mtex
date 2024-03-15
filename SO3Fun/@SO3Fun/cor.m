function val = cor(SO3F1,SO3F2,varargin)
% correlation between two SO3Funs
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

res = get_option(varargin,'resolution',2.5*degree);
nodes = equispacedSO3Grid(SO3F1.SRight,SO3F1.SLeft,'resolution',res);

value1 = SO3F1.eval(nodes(:));
value2 = SO3F2.eval(nodes(:));

val = (value1.' * conj(value2))/length(nodes);

end
