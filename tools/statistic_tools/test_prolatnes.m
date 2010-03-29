function T = test_prolatnes(n,kappa,lambda)
% bingham test for prolatnes shape
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

p = n/2.*(kappa(2,:)-kappa(3,:)).*(lambda(2,:)-lambda(3,:));

T = chi2pdf(p,2);
