function m = mean(pf,varargin)
% mean of pole figure intensities
%
% Syntax
%   m = mean(pf)
%
% Input
%  pf  - @PoleFigure
%
% Output
%  m  - mean
%

m = zeros(1,pf.numPF);
for i = 1:pf.numPF
  
  w = calcQuadratureWeights(pf.allR{i});
    
  m(i) = sum(sum(reshape(pf.allI{i},size(w)) .* w));
  
end
