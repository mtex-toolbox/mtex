function pf = normalize(pf,odf)
% normalization of a meassured pole figure with respect to an ODF
%
%% Syntax
% pf = normalize(pf)
% pf = normalize(pf,odf)
%
%% Input
%  pf  - @PoleFigure
%  odf - @ODF
%
%% Output
%  pf  - @PoleFigure
%
%% See also
% PoleFigure/calcerror

%% no ODF given 
if nargin == 1

  alpha = mean(pf);
  
%% ODF given
else
  for i = 1:length(pf)
    pf_odf(i) = simulatePoleFigure(odf,pf(i).h,pf(i).r,'superposition',pf(i).c); %#ok<AGROW>
  end

  alpha = calcnormalization(pf,pf_odf);
  
end

pf = pf ./ alpha;
