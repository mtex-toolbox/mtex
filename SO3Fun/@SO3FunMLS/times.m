function SO3F = times(SO3F1,SO3F2)
% overloads |SO3F1 .* SO3F2|
%
% Syntax
%   sF = SO3F1 .* SO3F2
%   sF = a .* SO3F2
%   sF = SO3F1 .* a
%
% Input
%  SO3F1, SO3F2 - @SO3FunMLS
%  a - double
%
% Output
%  SO3F - @SO3Fun
%

if isnumeric(SO3F1)
  SO3F = SO3F2;
  SO3F.values = reshape(SO3F1,[1,size(SO3F1)]).*SO3F.values;
  return
end
if isnumeric(SO3F2)
  SO3F = SO3F2 .* SO3F1;
  return
end

ensureCompatibleSymmetries(SO3F1,SO3F2);
if isa(SO3F1,'SO3FunMLS') && isa(SO3F2,'SO3FunMLS') && ...
    length(SO3F1.nodes) == length(SO3F2.nodes) && ...
    all(SO3F1.nodes(:) == SO3F2.nodes(:))
  
  SO3F = SO3F1;
  SO3F.values = SO3F.values .* SO3F2.values;
  return

end

SO3F = times@SO3Fun(SO3F1,SO3F2);
SO3F = SO3FunHarmonic(SO3F,'bandwidth', min(getMTEXpref('maxSO3Bandwidth'),SO3F1.bandwidth + SO3F2.bandwidth));

end