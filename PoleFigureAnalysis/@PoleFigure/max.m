function pf = max(pf1,pf2)
% maximum of two pole figures or the maximum of a single polefigure
%
% Syntax:
%   m  = max(pf)
%   pf = max(pf1,pf2)
%   pf = max(pf1,x) = max(x,pf1)
%
% Input
%  pf       - @PoleFigure
%  pf1, pf2 - @PoleFigure
%  x        - double
%
% Output
%  m  - double
%  pf - @PoleFigure

if nargin == 1
  
  pf = cellfun(@(x) max(x(:)),pf1.allI);    
    
elseif isa(pf1,'double')
  
  pf = pf2;
  pf.intensities = max(pf1,pf2.intensities);
    
elseif isa(pf2,'double')
  
  pf = pf1;
  pf.intensities = max(pf2,pf1.intensities);
    
else
  
  pf = pf1;
  pf.intensities = max(pf1.intensities,pf2.intensities);
    
end
