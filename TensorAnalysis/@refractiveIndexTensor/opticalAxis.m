function oA = opticalAxis(rI)
% optical axis or axes for a refractive index tensor
%
% Syntax
%   oA = opticalAxis(rI)
%
% Input
%  rI - @refractiveIndexTensor
%
% Output
%  oA - @vector3d
%

[v,n] = eig3(rI.M);

if n(1) == n(3)
  disp('  No optical axes. Refractive index tensor is isotropic');
elseif n(1) == n(2)
  oA = reshape(v(3,:),size(rI));
elseif n(2) == n(3)
  oA = reshape(v(1,:),size(rI));
else
  oA = reshape(sqrt((n(3)-n(2))./(n(3)-n(1))) .* v(3,:),[],1) * [-1 1] ...
    + repmat(reshape(sqrt((n(2)-n(1))./(n(3)-n(1))) .* v(1,:),[],1),1,2);
end
