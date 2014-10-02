function [ev,ew]= principalComponents(grains,varargin)
% returns the principalcomponents of grain polygon, without Holes
%
% Input
%  grains - @grain2d
%
% Output
%  cmp   - angle of components as complex
%  v     - length of axis
%
%
% See also
% polygon/hullprincipalcomponents grain/plotEllipse
%

% ignore holes
poly = cellfun(@(x) x(1:(1+find(x(2:end) == x(1),1))),grains.poly,'uniformOutput',false);

% vertices
V = grains.V;

% centroids
c = grains.centroid;

ew = zeros(2,2,numel(poly));
ev = zeros(2,2,numel(poly));
for k=1:numel(poly)
  
  % center polygon in centroid
  Vg = bsxfun(@minus,V(poly{k},:), c(k,:));
  
  % compute length of line segments
  ind = poly{k};
  dist = sqrt(sum((V(ind(1:end-1),:) - V(ind(2:end),:)).^2,2));
  weight = ([dist;0] + [0;dist])./2;
  
  % weight vertices according to half the length of the adjacent faces
  Vg = bsxfun(@times,Vg, weight);
  
  % pca
  [ev(:,:,k), ew(:,:,k)] = svd(Vg'*Vg);
  ew(:,:,k)  = nthroot(2*sqrt(2).*ew(:,:,k),2)./(nthroot(size(Vg,1),2));
end

end
