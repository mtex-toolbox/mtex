function x = linprogCentre(c,A,y,varargin)
% many small linear programs min c'x, A x = y, x >= 0 at once
%
% Description
% A primal dual path following interior point method on all problems
% simultaneously. Following the central path it ends in the analytic centre
% of the optimal solutions, which is symmetric whenever the problem is,
% where a simplex method returns an arbitrary vertex.
%
% Syntax
%   x = linprogCentre(c,A,y)
%
% Input
%  c - n x 1 or n x N costs
%  A - m x n or m x n x N constraint matrices
%  y - m x N right hand sides
%
% Output
%  x - n x N solutions, NaN where a problem did not converge
%
% Options
%  tolerance - relative accuracy (default 1e-9)
%  maxIter   - maximum number of iterations (default 100)
%

tol = get_option(varargin,'tolerance',1e-9);
maxIter = get_option(varargin,'maxIter',100);

[m,n,~] = size(A);
N = size(y,2);

% blocks of problems, to bound the memory
blk = 1e4;
if N > blk
  x = zeros(n,N);
  for k = 1:blk:N
    id = k:min(k+blk-1,N);
    x(:,id) = linprogCentre(c(:,min(id,end)),A(:,:,min(id,end)),y(:,id),varargin{:});
  end
  return
end

At = pagetranspose(A);
mul = @(B,v) reshape(pagemtimes(B,reshape(v,size(B,2),1,[])),size(B,1),[]);
c = c .* ones(1,N);

x = ones(n,N); s = ones(n,N); lambda = zeros(m,N);
for k = 1:maxIter

  % residuals and duality measure
  rp = y - mul(A,x);
  rd = c - mul(At,lambda) - s;
  mu = sum(x.*s,1) / n;
  ok = vecnorm(rp) <= tol*(1+vecnorm(y)) & vecnorm(rd) <= tol*(1+vecnorm(c)) & ...
    n*mu <= tol*(1+abs(sum(c.*x,1)));
  if all(ok | isnan(mu)), break; end

  % Newton step towards the central path at 0.3 mu
  rc = 0.3*mu - x.*s;
  M = pagemtimes(A .* reshape(x./s,1,n,[]),At);
  dlambda = reshape(pagemldivide(M,reshape(rp - mul(A,(rc - x.*rd)./s),m,1,[])),m,[]);
  ds = rd - mul(At,dlambda);
  dx = (rc - x.*ds) ./ s;
  dx(:,ok) = 0; ds(:,ok) = 0; dlambda(:,ok) = 0;

  % stay inside the positive orthant
  ap = 1 ./ max(1,max(-dx./x,[],1)/0.95);
  ad = 1 ./ max(1,max(-ds./s,[],1)/0.95);
  x = x + ap.*dx;
  s = s + ad.*ds;
  lambda = lambda + ad.*dlambda;

end

x(:,~ok) = NaN;
