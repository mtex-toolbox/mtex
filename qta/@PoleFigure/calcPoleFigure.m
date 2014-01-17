function spf = calcPoleFigure(pf,odf,varargin)
% simulate pole figure
%
% Syntax
%   pf = simulatePoleFigure(pf,odf)
%
% Input
%  pf  - meassured @PoleFigure
%  odf - @ODF
%
% Output
%  spf - PoleFigure 
%
% See also
% ODF/simulatePoleFigure

progress(0,length(pf));
for i = 1:length(pf)
    
  spf(i) = calcPoleFigure(odf,pf(i).h,pf(i).r,...
    'superposition',pf(i).c,varargin{:});
  progress(i,length(pf));
  
end
