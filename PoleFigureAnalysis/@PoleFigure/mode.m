function m = mode(pf,varargin)
% mode of pole figure intensities
%
% Syntax
%   m = mode(pf)
%
% Input
%  pf  - @PoleFigure
%
% Output
%  m  - mode
%

m = zeros(1,pf.numPF);
for i = 1:pf.numPF
    
  % Calculate weights
  w = calcQuadratureWeights(pf.allR{i});
  
  % Calculate weighted intensities
  weightedIntensities = reshape(pf.allI{i}, size(w)) .* w;
  
  % Make a 1D array
  intensities = weightedIntensities(:);
  
  % Find unique values and their frequencies
  [uniqueValues, ~, frequency] = unique(intensities);
  
  % Find the value(s) with the highest frequency
  modeIndex = uniqueValues(mode(frequency) == frequency);
  
  % If there are multiple modes, take the average
  if numel(modeIndex) > 1
      m(i) = mean(modeIndex);
  else
      m(i) = modeIndex;
  end
  
end
