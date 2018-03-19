function [omega,a,b]= principalComponents(grains,varargin)
% returns the principalcomponents of grain polygon, without Holes
%
% Input
%  grains - @grain2d
%
% Output
%  omega - angle of the ellipse
%  a     - length largest axis
%  b     - length smallest axis
%
% Options
%  area - scale a,b such that the corresponding ellipse has the same area as the grain (default)
%  boundary - scale a,b such that the corresponding ellipse has the boundary length as the grain
%
% See also
% plotEllipse
%

% ignore holes
poly = cellfun(@(x) x(1:(1+find(x(2:end) == x(1),1))),grains.poly,'uniformOutput',false);

% vertices
V = grains.V;

% centroids
c = grains.centroid;

omega = zeros(size(poly));
a = zeros(size(poly));
b = zeros(size(poly));

for k=1:numel(poly)
  
  % center polygon in centroid
  Vg = bsxfun(@minus,V(poly{k},:), c(k,:));
  
  % compute length of line segments
  dist = sqrt(sum((Vg(1:end-1,:) - Vg(2:end,:)).^2,2));
  dist = 0.5*(dist(1:end) + [dist(end);dist(1:end-1)]);
  
  %phi = atan2(Vg(:,2),Vg(:,1));
  %dist = mod(diff(phi([1:end 1]))+pi,2*pi)-pi;
  %dist = 0.5*(dist(1:end) + [dist(end);dist(1:end-1)]);
    
  % weight vertices according to half the length of the adjacent faces
  v = bsxfun(@times,Vg(1:end-1,:), dist./mean(dist));
      
  % compute eigen values and vectors
  [omega(k), ew] = eig2(v'*v,'angle');
    
  % halfaxes are square roots of the eigenvalues
  a(k) = sqrt(ew(1)); b(k) = sqrt(ew(2));
end

% compute scaling
if check_option(varargin,'boundary') % boundary length fit
  [~,E] = ellipke(sqrt((a.^2 - b.^2)./a.^2));
  scaling = grains.perimeter ./ a ./4 ./ E;
else % area fit
  scaling = sqrt(grains.area ./ a ./ b ./pi);
end

% scale halfaxes
a = a .* scaling; b = b .* scaling;

end

