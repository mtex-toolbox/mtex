function m = median(pf,varargin)
% median of pole figure intensities
%
% Syntax
%   m = median(pf)
%
% Input
%  pf  - @PoleFigure
%
% Output
%  m  - median
%

m = zeros(1,pf.numPF);
for i = 1:pf.numPF
    
  % Calculate weights
  w = calcQuadratureWeights(pf.allR{i});
  
  % Calculate weighted intensities
  weightedIntensities = reshape(pf.allI{i}, size(w)) .* w;
  
  % Sort intensities
  sortedIntensities = sort(weightedIntensities(:));
  
  % Calculate median
  numElements = numel(sortedIntensities);
  if mod(numElements, 2) == 0
      m(i) = (sortedIntensities(numElements/2) + sortedIntensities(numElements/2 + 1)) / 2;
  else
      m(i) = sortedIntensities((numElements + 1) / 2);
  end
  
end
