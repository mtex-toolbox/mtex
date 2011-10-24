function w = calcQuadratureWeights(S2G,varargin)
% compute the area of the Voronoi decomposition
%
%% Input
%  S2G - @S2Grid
%
%% Output
%  w - weights
%

%% check for regular grid
theta = get(S2G,'theta');
utheta = unique(theta(:));
rho = get(S2G,'rho');
urho = unique(rho(:));

if numel(S2G) == numel(utheta) * numel(urho) && min(utheta) == 0

  dtheta = utheta(2) - utheta(1);
    
  % compute quadrature weights
  N = pi / dtheta;
  w = fclencurt(N+1,-1,1);
  w = w(1:length(utheta));
  w = w ./ sum(w) ./ numel(theta) .* numel(utheta);
  w= repmat(w',numel(urho),1);
        
else
      
  % compute weights as the area of the voronoi cells
  w = nan;
  i = 1;
  while i< 10 && (any(isnan(w)) || any(imag(w)))
    w = calcVoronoiArea(S2G)./4./pi;
    i = i+1;
  end
    
  % dont allow weights to become to large
  m = quantile(w(:),0.8);
  w(w>m) = 1 * max(w(w<=m));
  
end

if any(isnan(w)) || any(imag(w)), w = 1./numel(S2G);end
