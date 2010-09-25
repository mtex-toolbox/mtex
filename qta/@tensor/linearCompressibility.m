function out = linearCompressibility(E,v)
% computes the linear compressibility of an elasticity tensor
%
%% Description
% formula: out = S_ijkk x_i x_j
%
%% Input
%  E - elasticity @tensor
%  v - list of @vector3d
%
%% Output
%  out - linear compressibility in directions v
%

% compute the complience
S = inv(E);

% take the mean along the diagonal
M = S.M;
S.M = zeros(3,3);
S.rank = 2;
for i = 1:3
  for j = 1:3
    S.M(i,j) = sum(diag(squeeze(M(i,j,:,:))));
  end
end


% now compute the quadric
out = quadric(S,v);
