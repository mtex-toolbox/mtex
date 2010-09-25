function [vp,vs1,vs2,pp,ps1,ps2] = velocity(E,x,rho)
% computes the elastic wave velocity from an elasticity tensor
%
%% Input
% E   - elasticity @tensor
% x   - list of propagation directions (@vector3d)
% rho - material density
%
%% Output
% vp  - velocity of the p-wave
% vs1 - velocity of the s1-wave
% vs2 - velocity of the s2-wave
% pp  - polarisation of the p-wave (particle movement, vibration direction)
% ps1 - polarisation of the s1-wave (particle movement, vibration direction)
% ps2 - polarisation of the s2-wave (particle movement, vibration direction)
%

% compute CristoffelTensor
T = CristoffelTensor(E,x);

% from output
vp = zeros(size(x));
vs1 = zeros(size(x));
vs2 = zeros(size(x));
pp = repmat(vector3d,size(rho));
ps1 = repmat(vector3d,size(rho));
ps2 = repmat(vector3d,size(rho));

% for each direction
for i = 1:numel(x)
  
  % compute eigenvalues
  [V,D] = eigs(T.M(:,:,i));
  
  % compute wavespeeds
  D = sqrt(diag(D)/rho);

  % the speeds
  vp(i) = D(3);
  vs1(i) = D(2);
  vs2(i) = D(1);
  
  % the polarisation axes
  pp(i) = vector3d(V(:,3));
  ps1(i) = vector3d(V(:,2));
  ps2(i) = vector3d(V(:,1));
  
end
