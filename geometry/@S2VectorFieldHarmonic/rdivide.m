function sVF = rdivide(sVF1, sVF2)
%
% Syntax
%  sVF = sVF1/a
%

if isnumeric(sVF2)
  sVF = sVF1.*(1./sVF2)
end

end
