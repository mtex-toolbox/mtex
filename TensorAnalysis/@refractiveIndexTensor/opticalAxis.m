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

[v,lambda] = eig3(rI.M);

if lambda(1) == lambda(3)
  disp('  No optical axes. Refractive index tensor is isotropic');
elseif lambda(1) == lambda(2)
  oA = reshape(v(1,:),size(rI));
elseif lambda(2) == lambda(3)
  oA = reshape(v(3,:),size(rI));
else
  oA = reshape(sqrt((lambda(3)-lambda(2))./(lambda(3)-lambda(1))) .* v(3,:),[],1) * [-1 1] ...
    + repmat(reshape(sqrt((lambda(2)-lambda(1))./(lambda(3)-lambda(1))) .* v(1,:),[],1),1,2);
end
