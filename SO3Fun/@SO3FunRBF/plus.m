function SO3F = plus(SO3F1,SO3F2)
% overloads SO3F1 + SO3F2
%
% Syntax
%   sF = SO3F1 + SO3F2
%   sF = a + SO3F1
%   sF = SO3F1 + a
%
% Input
%  SO3F1, SO3F2 - @SO3FunRBF
%
% Output
%  SO3F - @SO3Fun
%

if isnumeric(SO3F1)
  
  SO3F = SO3F2;
  SO3F.c0 = SO3F.c0 + SO3F1;
  
elseif isnumeric(SO3F2)
  
  SO3F = SO3F1;
  SO3F.c0 = SO3F.c0 + SO3F2;
  
elseif isa(SO3F2,'SO3Fun')
  
  f = @(v) SO3F1.eval(v) + SO3F2.eval(v);
  SO3F = SO3FunHarmonic.quadrature(f, 'bandwidth', ...
    min(getMTEXpref('maxBandwidth'),max(SO3F1.bandwidth,SO3F2.bandwidth)));
  
else
  SO3F = SO3F2 .* SO3F1;
end

end
