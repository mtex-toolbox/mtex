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
  
elseif isa(SO3F1,'SO3FunRBF') && isa(SO3F2,'SO3FunRBF') && ...
    length(SO3F1.center) == length(SO3F2.center) && ...
    all(SO3F1.center == SO3F2.center) && SO3F1.psi == SO3F2.psi

  SO3F = SO3F1;
  SO3F.weights = SO3F.weights + SO3F2.weights;
  SO3F.c0 = SO3F.c0 + SO3F2.c0;
  
elseif isa(SO3F1,'SO3FunRBF') && isa(SO3F2,'SO3FunRBF') && ...
    length(SO3F1.center) < 100 && length(SO3F2.center)<100 && ...
    SO3F1.psi == SO3F2.psi
  
  SO3F = SO3F1;
  SO3F.weights = [SO3F.weights;SO3F2.weights];
  SO3F.center = [SO3F.center;SO3F2.center];
  SO3F.c0 = SO3F.c0 + SO3F2.c0;
  
else
  
  SO3F = plus@SO3Fun(SO3F1,SO3F2);
  
  %f = @(v) SO3F1.eval(v) + SO3F2.eval(v);
  %SO3F = SO3FunHarmonic.quadrature(f, 'bandwidth', ...
  %  min(getMTEXpref('maxSO3Bandwidth'),max(SO3F1.bandwidth,SO3F2.bandwidth)));

end

end
