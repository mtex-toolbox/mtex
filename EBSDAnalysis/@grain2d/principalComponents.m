function [a,b]= principalComponents(grains,varargin)
% returns the principalcomponents of grain polygon, without Holes
% in this version omega is no longer supported, use a.rho instead.
%
% Input
%  grains - @grain2d
%
% Output
%  a     - length largest axis @vector3d
%  b     - length smallest axis @vector3d
%
% Options
%  area - scale a,b such that the corresponding ellipse has the same area as the grain (default)
%  boundary - scale a,b such that the corresponding ellipse has the boundary length as the grain
%
% See also
% plotEllipse
%

if dot(grains.N,zvector) ~= 1

  [grains,rot] = rotate2Plane(grains);
  [a,b] = principalComponents(grains, varargin);
  a=rot\a;
  b=rot\b;
  return

end

% ignore holes
poly = cellfun(@(x) x(1:(1+find(x(2:end) == x(1),1))),grains.poly,'uniformOutput',false);

% extract vertices
V = grains.V(:,1:2);

% centroids
c = [grains.centroid.x, grains.centroid.y];

% loop over all grains
omega = zeros(size(poly)); a = omega; b = omega;
for k=1:numel(poly)
  
  % center polygon in centroid
  Vg = V(poly{k},:) - repmat(c(k,:),length(poly{k}),1);
  
  % compute length of line segments
  dist = sqrt(sum((Vg(1:end-1,:) - Vg(2:end,:)).^2,2));
  dist = 0.5*(dist(1:end) + [dist(end);dist(1:end-1)]);
     
  % weight vertices according to half the length of the adjacent faces
  Vg = Vg(1:end-1,:) .* [dist,dist] .* sum(Vg(1:end-1,:).^2,2).^(0.25);
      
  % compute eigen values and vectors
  [ew, omega(k)] = eig2(Vg' * Vg);
    
  % halfaxes are square roots of the eigenvalues
  b(k) = sqrt(ew(1)); a(k) = sqrt(ew(2));
end

% compute scaling
if check_option(varargin,'boundary') % boundary length fit
  [~,E] = ellipke(sqrt((a.^2 - b.^2)./a.^2));
  scaling = grains.perimeter ./ a ./4 ./ E;
else % area fit
  scaling = sqrt(grains.area ./ a ./ b ./pi);
end

% scale half axes
a = a .* scaling; b = b .* scaling;

a=a.*vector3d.byPolar(pi/2,omega);
b=b.*vector3d.byPolar(pi/2,omega+pi/2);

end

