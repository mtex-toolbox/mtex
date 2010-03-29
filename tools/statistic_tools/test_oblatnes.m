function T = test_oblatnes(n,kappa,lambda)
% bingham test for oblate case
%
%% Input
%  n      - number of points
%  kappa  - bingham parameter 4xM
%  lambda - eigenvalues of bingam 4xM
%
%% See also
%  evalkappa

if isempty(kappa)
  %c_hat ...
  return
end

kappa = sort(kappa,'descend');
lambda = sort(lambda,'descend');

p = n/2.*(kappa(3,:)-kappa(4,:)).*(lambda(3,:)-lambda(4,:));

T = chi2pdf(p,2);

