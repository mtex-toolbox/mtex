function pf = normalize(pf,odf)
% normalization of a meassured pole figure with respect to an ODF
%
% Syntax
%   pf = normalize(pf)
%   pf = normalize(pf,odf)
%
% Input
%  pf  - @PoleFigure
%  odf - @ODF
%
% Output
%  pf  - @PoleFigure
%
% See also
% PoleFigure/calcError

% no ODF given 
if nargin == 1

  alpha = mean(pf);
  
% ODF given
else
  
  % recalculate pole figures
  pf_odf = calcPoleFigure(odf,pf.allH,pf.allR,'superposition',pf.c);
  
  % compute normalization
  alpha = calcNormalization(pf,pf_odf);
  
end

pf = pf ./ alpha;
