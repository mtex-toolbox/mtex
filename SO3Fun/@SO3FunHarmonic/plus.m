function SO3F = plus(SO3F1, SO3F2)
% implements SO3F1 + SO3F2
%
% Syntax
%   SO3F = SO3F1+SO3F2
%   SO3F = a+SO3F1
%   SO3F = SO3F1+a
%

if isnumeric(SO3F1) %&& ( length(SO3F1) == 1 || all(size(SO3F1)==size(SO3F2)) ) 
  s = size(SO3F2);
  SO3F = SO3F2.subSet(':');
  SO3F.fhat(1, :) = SO3F.fhat(1, :)+SO3F1(:).';
  SO3F = reshape(SO3F, s);
  return
end
if isnumeric(SO3F2) %&& ( length(SO3F2) == 1 || all(size(SO3F1)==size(SO3F2)) )
  s = size(SO3F1);
  SO3F = SO3F1.subSet(':');
  SO3F.fhat(1, :) = SO3F.fhat(1, :)+SO3F2(:).';
  SO3F = reshape(SO3F, s);
  return
end


% if isa(SO3F1,'SO3FunHarmonic') && isa(SO3F2,'SO3Fun')
  SO3F1 = SO3FunHarmonic(SO3F1);
  SO3F2 = SO3FunHarmonic(SO3F2);

  [~, index] = max([SO3F1.bandwidth, SO3F2.bandwidth]);
  if index == 1
    SO3F2.bandwidth = SO3F1.bandwidth;
  else
    SO3F1.bandwidth = SO3F2.bandwidth;
  end

  SO3F = SO3F1;
  SO3F.fhat = SO3F1.fhat + SO3F2.fhat;
%  return
% end
% 
% error('Operator + is not supported for operands of this types.')


