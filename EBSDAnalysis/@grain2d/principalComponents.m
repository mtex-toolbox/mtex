function [a,b] = principalComponents(grains,varargin)
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

% ignore holes
poly = cellfun(@(x) x(1:(1+find(x(2:end) == x(1),1))),grains.poly,'uniformOutput',false);

if isscalar(grains) % 3d algorithm (more nice :))
  
  % centroids
  c = grains.centroid;
  V = grains.allV;

  % loop over all grains
  a = vector3d.nan(length(grains),1); a.antipodal = true;
  b = a;
  for k = 1:length(grains)
    
    % center polygon in centroid
    Vg = V(poly{k}) - c(k);
  
    % compute length of line segments
    dist = norm(Vg(1:end-1) - Vg(2:end));
    dist = 0.5*(dist(1:end) + [dist(end);dist(1:end-1)]);
     
    % weight vertices according to half the length of the adjacent faces
    Vg = Vg(1:end-1) .* [dist,dist] .* sqrt(norm(Vg(1:end-1)));
      
    % compute eigen values and vectors
    [eVec, eVal] = eig3(Vg * Vg);
    
    % halfaxes are square roots of the eigenvalues
    a(k) = sqrt(eVal(3)) * eVec(3);
    b(k) = sqrt(eVal(2)) * eVec(2);
    
  end
else % 2d algorithm
  
  rot = grains.rot2Plane;
  V = rot .* grains.allV;
  V = [V.x(:),V.y(:)];
  
  % centroids
  c = rot * grains.centroid;
  c = [c.x(:),c.y(:)];

  % loop over all grains
  a = nan(numel(poly),2); b = a;
  for k=1:numel(poly)
  
    % center polygon in centroid
    Vg = V(poly{k},:) - repmat(c(k,:),length(poly{k}),1);
  
    % compute length of line segments
    dist = sqrt(sum((Vg(1:end-1,:) - Vg(2:end,:)).^2,2));
    dist = 0.5*(dist(1:end) + [dist(end);dist(1:end-1)]);
     
    % weight vertices according to half the length of the adjacent faces
    Vg = Vg(1:end-1,:) .* [dist,dist] .* sum(Vg(1:end-1,:).^2,2).^(0.25);
      
    % compute eigen values and vectors
    %[ew, omega(k)] = eig2(Vg' * Vg);
    [vec,val] = eig(Vg' * Vg,'vector');

    a(k,:) = sqrt(val(2)) .* vec(2,:);
    b(k,:) = sqrt(val(1)) .* vec(1,:);

  end

  a = inv(rot) .* vector3d(a(:,1),a(:,2),0,'antipodal');
  b = inv(rot) .* vector3d(b(:,1),b(:,2),0,'antipodal');

end

% compute scaling
if check_option(varargin,'boundary') % boundary length fit
  [~,E] = ellipke(sqrt((norm(a).^2 - norm(b).^2)./norm(a).^2));
  scaling = grains.perimeter ./ a ./4 ./ E;
else % area fit
  scaling = sqrt(grains.area ./ norm(a) ./ norm(b) ./pi);
end

% scale half axes
a = a .* scaling; b = b .* scaling;

end
