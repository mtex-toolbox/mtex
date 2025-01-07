function sF = times(sF1,sF2)
% overloads |sF1 .* sF2|
%
% Syntax
%   sF = sF1 .* sF2
%   sF = a .* sF2
%   sF = sF1 .* a
%
% Input
%  sF1, sF2 - @S1Fun
%  a - double
%
% Output
%  sF - @S1Fun
%

if isnumeric(sF1)
  dim = length(size(sF1));
  sF = S1FunHandle(@(o) permute(sF1,[dim+1 1:dim]) .* sF2.eval(o));
  return
end

if isnumeric(sF2)
  sF = sF2 .* sF1;
  return
end

sF = S1FunHandle(@(o) sF1.eval(o) .* sF2.eval(o));

end