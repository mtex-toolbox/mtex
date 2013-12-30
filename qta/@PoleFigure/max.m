function m = max(pf,pf2)
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
  
  for i =1:length(pf)
    m(i) = max(pf(i).intensities(:));
  end
  
elseif isa(pf,'double')
  
  m = pf2;
  for i = 1:length(pf2)
    m(i).intensities = max(pf,pf2(i).intensities);
  end
  
elseif isa(pf2,'double')
  
  m = pf;
  for i = 1:length(pf)
    m(i).intensities = max(pf2,pf(i).intensities);
  end
  
else
  
  m = pf2;
  for i = 1:length(pf2)
    m(i).intensities = max(pf(i).intensities,pf2(i).intensities);
  end
  
end
