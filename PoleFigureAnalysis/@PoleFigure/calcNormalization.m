function alpha = calcNormalization(pf1,pf2)
% normalization of a meassured pole figure with respect to a second pole figure
%
% Syntax
%   alpha = calcNormalization(pf1,pf2)
%
% Input
%  pf1,pf2 - @PoleFigure
%
% Output
%  alpha - [double] normalization coefficients
%
% See also
% PoleFigure/calcError

for i = 1:pf1.numPF
  d1 = max(0,pf1.allI{i});
  d2 = max(0,pf2.allI{i});
  
  w = calcQuadratureWeights(pf1.allR{i});
  
  alpha(i) = sum(w(:)'*d1(:) / (w(:)'*d2(:))); %#ok<AGROW>
end
