function [omega, oriF] = angle(f,ori,varargin)
% angle fiber to orientation or fiber to fibre
%
% Syntax
%
%   omega = angle(f,ori) % angle orientation to fibre
%   [omega, oriF] = angle(f,ori)
%
%   omega = angle(f1,f2) % angle fibre to fibre
%
% Description
% The angle of an orientation to the fibre h||r is the angle between ori*h
% and r, the least over the images of h under the crystal point group and
% of r under the specimen point group, the improper elements included: in a
% centrosymmetric crystal -h is an equivalent of h. It is computed from the
% chord of the closest pair, accurate near the fibre.
%
% Input
%  f, f1, f2 - @fibre
%  ori - @orientation
%
% Output
%  omega - double
%  oriF  - @orientation on an equivalent fibre that minimizes the angle
%
% See also
% orientation/angle fibre/symmetrise

if ~isa(ori,'orientation')
  omega = max(angle(f,orientation(ori),varargin{:}));
  return
end

% the images of h and r under the point groups, as rows
H = uniqueRows(symmetrise(f.h));
R = uniqueRows(f.SS.rot * f.r);
ap = check_option(varargin,'antipodal');

% the closest pair: r' read in the crystal frame of every orientation
g = rotation(ori(:));
best = -inf(numel(g),1); bh = ones(numel(g),1); br = ones(numel(g),1);
for j = 1:size(R,1)
  v = inv(g) .* vector3d(R(j,1),R(j,2),R(j,3));
  d = [v.x(:),v.y(:),v.z(:)] * H.';
  if ap, d = abs(d); end
  [dm,i] = max(d,[],2);
  upd = dm > best;
  best(upd) = dm(upd); bh(upd) = i(upd); br(upd) = j;
end

% the angle from the chord of that pair
v = inv(g) .* vector3d(R(br,1),R(br,2),R(br,3));
V = [v.x(:),v.y(:),v.z(:)];
Hb = H(bh,:);
if ap, Hb = Hb .* sign(sum(V .* Hb,2) + (sum(V .* Hb,2)==0)); end
omega = reshape(2*asin(min(1,vecnorm(V - Hb,2,2)/2)),size(ori));

if nargout == 2 % the nearest orientation, on the fibre of that pair
  rotH = rotation.map(vector3d(Hb(:,1),Hb(:,2),Hb(:,3)),v);
  oriF = reshape(ori(:) .* rotH,size(ori));
end

end


% the distinct unit vectors, as rows
function X = uniqueRows(v)
v = normalize(vector3d(v));
X = uniquetol([v.x(:),v.y(:),v.z(:)],1e-9,'ByRows',true,'DataScale',1);
end
