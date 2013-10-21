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

for i = 1:length(pf1)
  d1 = max(0,pf1(i).intensities);
  d2 = max(0,pf2(i).intensities);
  
  w = calcQuadratureWeights(pf1(i).r);
  
  alpha(i) = sum(w(:)'*d1(:) / (w(:)'*d2(:))); %#ok<AGROW>
end
