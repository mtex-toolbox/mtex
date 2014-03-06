function m = mean(pf,varargin)
% mean of pole figure intensities
%
%% Syntax
% m = mean(pf)
%
%% Input
%  pf  - @PoleFigure
%
%% Output
%  m  - mean
%

m = zeros(size(pf));
for i = 1:length(pf)
  
  w = calcQuadratureWeights(pf(i).r);
    
  m(i) = sum(sum(reshape(pf(i).data,size(w)) .* w));
  
end
