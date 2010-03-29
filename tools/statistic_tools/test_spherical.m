function T = test_spherical(n,kappa,lambda)
% bingham test for spherical case
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

mkappas = mean(kappa(2:4,:));
mlambdas = mean(lambda(2:4,:));

slam = @(i) (kappa(i,:)-mkappas).*(lambda(i,:)-mlambdas);


p = n.*(slam(2)+slam(3)+slam(4));

% TODO: chi2pdf without statistic toolbox..

T = chi2pdf(p,5);
