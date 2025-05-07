function SO3F = rdivide(SO3F1, SO3F2)
% overloads ./
%
% Syntax
%   SO3F = SO3F1 ./ SO3F2
%   SO3F = SO3F1 ./ a
%   SO3F = a ./ SO3F2
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
  SO3F.values = reshape(SO3F1,[1,size(SO3F1)]) ./ SO3F.values;
  if any(isinf(SO3F.values))
    warning('After division, the resulting function has Inf values.'); 
  end
  return
end
if isnumeric(SO3F2)
  SO3F = times(SO3F1,1./SO3F2);
  return
end

ensureCompatibleSymmetries(SO3F1,SO3F2);
if isa(SO3F1,'SO3FunMLS') && isa(SO3F2,'SO3FunMLS') && ...
    length(SO3F1.nodes) == length(SO3F2.nodes) && ...
    all(SO3F1.nodes(:) == SO3F2.nodes(:))
  
  SO3F = SO3F1;
  SO3F.values = SO3F.values ./ SO3F2.values;
  return

end

SO3F = rdivide@SO3Fun(SO3F1,SO3F2);


end

