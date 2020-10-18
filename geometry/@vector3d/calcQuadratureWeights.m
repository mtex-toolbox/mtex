function w = calcQuadratureWeights(v,varargin)
% compute the area of the Voronoi decomposition
%
% Input
%  S2G - @S2Grid
%
% Output
%  w - weights
%

% check for regular grid
utheta = unique(v.theta(:));
urho = unique(v.rho(:));

if length(v) == length(utheta) * length(urho) && min(utheta) == 0

  dtheta = utheta(2) - utheta(1);
    
  % compute quadrature weights
  N = pi / dtheta;
  w = fclencurt(N+1,-1,1);
  w = w(1:length(utheta));
  w = w ./ sum(w) ./ length(v) .* numel(utheta);
  w= repmat(w',numel(urho),1);
        
else
      
  % remove duplicated points
  [uV,~,n] = unique(v);
  
  % compute weights as the area of the voronoi cells
  w = calcVoronoiArea(uV)./4./pi;

  % compute weights
  o = accumarray(n,1);
  w = w./o;
  
  % redistribute weights
  w = w(n);
    
  % dont allow weights to become to large
  wmax = 2*quantile(w(:),0.8);
  w(w>wmax) = 1 * max(w(w<=wmax));
  
  % normalize
  w = w ./ sum(w);
  
end

if any(isnan(w(:))) || any(imag(w(:))), w = 1./length(v);end

