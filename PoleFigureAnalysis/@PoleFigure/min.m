function pf = min(pf1,pf2)
% minimum of two pole figures or the minimum of a single polefigure
%
% Syntax:
%   m  = min(pf)
%   pf = min(pf1,pf2)
%   pf = min(pf1,intensity)
%   pf = min(intensity,pf1)
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
  
  pf = cellfun(@(x) min(x(:)),pf1.allI);    
    
elseif isa(pf1,'double')
  
  pf = pf2;
  pf.intensities = min(pf1,pf2.intensities);
    
elseif isa(pf2,'double')
  
  pf = pf1;
  pf.intensities = min(pf2,pf1.intensities);
    
else
  
  pf = pf1;
  pf.intensities = min(pf1.intensities,pf2.intensities);
    
end
