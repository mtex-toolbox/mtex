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
%
% See also
% grain2d/plotEllipse
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
  Vg = bsxfun(@minus,V(poly{k}(1:end-1),:), c(k,:));
  
  %
  if check_option(varargin,'hull')
    ind = convhulln(Vg);
    Vg = Vg(ind(:,1),:);
  end
  
  % compute length of line segments
  dist = sqrt(sum((Vg(:,:) - Vg([2:end 1],:)).^2,2));
  
  dist = 0.5*(dist(1:end) + [dist(end);dist(1:end-1)]);
  
  % weight vertices according to half the length of the adjacent faces
  Vg = bsxfun(@times,Vg, dist./mean(dist));
    
  % pca
  [ev, ew] = svd(Vg'*Vg);
  
  omega(k) = atan2(ev(2),ev(1));
  
  ew = sqrt(sqrt(2) * ew / length(dist));
  
  a(k) = ew(1);
  b(k) = ew(4);
 
end

end
