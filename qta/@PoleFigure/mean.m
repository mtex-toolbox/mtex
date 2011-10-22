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
  
  % for regular grids 
  if size(pf(i).data,1) ~= 1 && size(pf(i).data,2) ~= 1
  
    % analyze spherical grid
    theta = get(pf(i).r,'theta');
    utheta = unique(theta);
    dtheta = utheta(2) - utheta(1);
    
    % compute quadrature weights
    N = pi / dtheta;
    w = fclencurt(N,-1,1);
    w = w(1:length(utheta));
    w = w ./ sum(w) ./ numel(theta) .* numel(utheta);
        
  else
    
    w = 1./numel(pf(i).data);
    
  end
    
  m(i) = sum(reshape(pf(i).data,size(pf(i).r)) * w);
  
end
