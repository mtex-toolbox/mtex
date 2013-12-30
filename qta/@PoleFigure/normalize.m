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
  %TODO
  pf_odf = calcPoleFigure(odf,pf(1).h,pf(1).r,'superposition',pf(1).c);
  for i = 2:length(pf)
    pf_odf(i) = calcPoleFigure(odf,pf(i).h,pf(i).r,'superposition',pf(i).c);
  end

  alpha = calcNormalization(pf,pf_odf);
  
end

pf = pf ./ alpha;
