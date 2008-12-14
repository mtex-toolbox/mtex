function [ m kappa v] = mean( ebsd )
% returns mean, kappas and eigenvector of ebsd object
%
%% Input
%  ebsd      - list of @ebsd
%
%% Output
%  m         - one equivalent mean orientation @quaternion
%  kappa     - parameters of bingham distribution
%  v         - eigenvectors of kappa
%

m = quaternion;
kappa = zeros(4,4,numel(ebsd));
v = zeros(4,4,numel(ebsd));

for i=1:numel(ebsd)
  if GridLength(ebsd.orientations(i)) > 0
    [m(i) kappa(:,:,i)  v(:,:,i)]  = mean(ebsd.orientations(i));
  end
end
