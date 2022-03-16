function SO3F = times(SO3F1,SO3F2)
% overloads SO3F1 .* SO3F2
%
% Syntax
%   sF = SO3F1 .* SO3F2
%   sF = a .* SO3F1
%   sF = SO3F1 .* a
%
% Input
%  SO3F1, SO3F2 - @SO3FunRBF
%
% Output
%  SO3F - @SO3Fun
%

if isnumeric(SO3F1)
  
  SO3F = SO3F2;
  SO3F.weights = SO3F.weights .* SO3F1;
  SO3F.c0 = SO3F.c0 .* SO3F1;  
  
elseif isnumeric(SO3F2)
  
  SO3F = SO3F1;
  SO3F.weights = SO3F.fhat .* SO3F2;
  SO3F.c0 = SO3F.c0 .* SO3F2;  
  
elseif isa(SO3F2,'SO3Fun')
  
  SO3F = times@SO3Fun(SO3F1,SO3F2);
  SO3F = SO3FunHarmonic(SO3F,'bandwidth', min(getMTEXpref('maxSO3Bandwidth'),SO3F1.bandwidth + SO3F2.bandwidth));
    
else
  SO3F = SO3F2 .* SO3F1;
end

end
