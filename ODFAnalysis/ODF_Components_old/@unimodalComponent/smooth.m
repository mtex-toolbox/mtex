function component = smooth(component,varargin)
% smooth ODF component
%
% Input
%  component - @ODFComponent
%  res - resolution
%
% Output
%  component - smoothed @ODFComponent
%

%TODO

% generate grid
S3G = equispacedSO3Grid(component.CS,component.SS,'resolution',hw);

% restrict single orientations to this grid

% init variables
g = quaternion(component.center);
d = zeros(1,length(S3G));

% iterate due to memory restrictions?
maxiter = ceil(numProper(component.CS)*numProper(component.SS)*length(g) /...
  getMTEXpref('memory',300 * 1024));
if maxiter > 1, progress(0,maxiter);end

for iter = 1:maxiter
  
  if maxiter > 1, progress(iter,maxiter); end
  
  dind = ceil(length(g) / maxiter);
  sind = 1+(iter-1)*dind:min(length(g),iter*dind);
  
  ind = find(S3G,g(sind));
  for i = 1:length(ind)
    d(ind(i)) = d(ind(i)) + component.weights(sind(i));
  end
  
end
d = d ./ sum(component.weights);

% eliminate spare rotations in grid
S3G = subGrid(S3G,d ~= 0);
d = d(d~=0);

component.center = S3G;
component.weights = d;
component.psi = component.psi * psi;

end

