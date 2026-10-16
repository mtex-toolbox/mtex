function value = sum(S2F,d)
% integral of an S2FunMLS, or the sum along a dimension of a vector valued one
%
% Syntax
%   value = sum(S2F)
%   S2F = sum(S2F,d)
%
% Input
%  S2F - @S2FunMLS
%  d   - dimension to sum along
%
% Output
%  value - double
%  S2F   - @S2FunMLS
%

if nargin == 1
  value = 4*pi*mean(S2F);
else
  S2F.values = sum(S2F.values,d+1);
  value = S2F;
end

end
