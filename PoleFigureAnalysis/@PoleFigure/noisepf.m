function pf = noisepf(pf,fak,background,varargin)
% simulate diffraction counts
%
% noisepf simulates realistic diffraction counts by generating random
% samples of the Poisson distribution with mean m = alpha * pdf + bg
%
% Syntax
%   pdfn = noisepf(pdf,alpha,bg)
%
% Input
%  pf    - @PoleFigure
%  alpha - uniform radiation (double)
%  bg    - background radiation (double)
%
% Options
%  NONNEGATIV - force data to be non negative
%
% See also
% ODF/calcPoleFigure

if nargin == 2, background = 0;end
if numel(fak) == 1, fak = repmat(fak,pf.numPF,1);end

for i = 1:pf.numPF
  pf.allI{i} = ...
  randp(fak(i)*pf.allI{i} + background) - background;  
  if check_option(varargin,'NONNEGATIV')
    pf.allI{i}(pf.allI{i} < 0) = 0;
  end  
end
