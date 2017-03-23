function [h1,h2,d1,d2] = round2Miller(mori,varargin)
% find h1,h2,d1,d2 such that ori * h1 = h2 and ori*d1=d2
%
% Syntax
%   [h1,h2,d1,d2] = round2Miller(mori)
%   [h1,h2,d1,d2] = round2Miller(mori,'penalty',0.01)
%   [h1,h2,d1,d2] = round2Miller(mori,'maxIndex',6)
%
% Input
%  mori - mis@orientation
%
% Output
%  h1,h2,d1,d2 - @Miller
%
% See also
% 

% maybe more then one orientation should be transformed
if length(mori) > 1
  h1 = Miller.nan(size(mori),mori.CS);
  h2 = Miller.nan(size(mori),mori.SS);
  d1 = Miller.nan(size(mori),mori.CS);
  d2 = Miller.nan(size(mori),mori.SS);
  for i = 1:length(ori)
    [h1(i),h2(i),d1(i),d2(i)] = round2Miller(mori.subSet(i),varargin{:});
  end
  return
end

penalty = get_option(varargin,'penalty',0.002);

maxIndex = get_option(varargin,'maxIndex',4);

% all plane normales
[h,k,l] =meshgrid(0:maxIndex,-maxIndex:maxIndex,-maxIndex:maxIndex);
h1 = Miller(h(:),k(:),l(:),mori.CS);
h2 = mori * h1;
rh2 = round(h2);
hkl2 = rh2.hkl;

% fit of planes
omega_h = angle(rh2,h2) + ...
  (h(:).^2 + k(:).^2 + l(:).^2 + sum(hkl2.^2,2)) * penalty;

% all directions
[u,v,w] = meshgrid(0:maxIndex,-maxIndex:maxIndex,-maxIndex:maxIndex);
d1 = Miller(u(:),v(:),w(:),mori.CS,'uvw');
d2 = mori * d1;
rd2 = round(d2);
uvw2 = rd2.uvw;

% fit of directions
omega_d = angle(rd2,d2) + ...
  (u(:).^2 + v(:).^2 + w(:).^2 + sum(uvw2.^2,2)) * penalty;

% directions should be orthognal to normals
fit = bsxfun(@plus,omega_h(:),omega_d(:).') + 10*(pi/2-angle_outer(h1,d1));

[~,ind] = nanmin(fit(:));
[ih,id] = ind2sub(size(fit),ind);

h1 = h1(ih);
d1 = d1(id);
h2 = round(mori * h1);
d2 = round(mori * d1);

end

% mori = orientation('map',Miller(1,1,-2,0,CS),Miller(2,-1,-1,0,CS),Miller(-1,0,1,1,CS),Miller(1,0,-1,1,CS)) * orientation('axis',vector3d.rand(1),'angle',1*degree,CS,CS)
% 

