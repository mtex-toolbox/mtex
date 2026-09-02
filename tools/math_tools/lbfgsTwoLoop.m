function d = lbfgsTwoLoop(g,S,Y)
% the two loop recursion of L-BFGS
%
% Applies the inverse Hessian approximation built from the secant pairs in S
% and Y to the gradient g without ever forming a matrix - only inner products
% of the stored vectors are needed. An empty memory gives the negative
% gradient, i.e. the step of steepest descent.
%
% Syntax
%   d = lbfgsTwoLoop(g,S,Y)
%
% Input
%  g    - gradient, as a column
%  S, Y - the steps taken and the changes of the gradient, one pair per column
%
% Output
%  d - descent direction
%
% See also
% S2Fun/optimalSample SO3Fun/optimalSample

k = size(S,2);

if k == 0, d = -g; return, end

rho = zeros(k,1);
a = zeros(k,1);

q = g;
for j = k:-1:1
  rho(j) = 1./(Y(:,j).'*S(:,j));
  a(j) = rho(j)*(S(:,j).'*q);
  q = q - a(j)*Y(:,j);
end

% initial inverse Hessian, scaled by the most recent pair - this is the step
% length that makes the unit trial step of the line search the right one
q = q * (S(:,k).'*Y(:,k))/(Y(:,k).'*Y(:,k));

for j = 1:k
  b = rho(j)*(Y(:,j).'*q);
  q = q + S(:,j)*(a(j)-b);
end

d = -q;

end
