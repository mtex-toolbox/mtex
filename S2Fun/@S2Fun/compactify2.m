function [v,c] = compactify2(f,varargin)
%
%
%

%% Predefinitions

% specify bandwidth until which polynomials should be integrated exactly
bw = get_option(varargin,'bandwidth',128);

% load density function
f = S2FunHarmonic(f,'bandwidth',bw);
f.bandwidth = bw;
lambda = mean(f);

% get starting points
M = get_option(varargin,'points',1000);
if isa(M,'vector3d')
  v = M;
else
  v = equispacedS2Grid('points',M)';
end
M = numel(v);
v = v(:);

% construct starting weights
c = ones(M,1)/M;

% Define Restricted Distance Kernel
n = (0:bw+1);
% In the paper: psi = S2Kernel( 4./(2*n-1)./(2*n+3) ); is the same as S2KernelHandle(@(x) -2*sin(acos(x)/2)) in MTEX other normalization of coeffs 
psi = S2Kernel(16*pi./((2*n+1).*(2*n-1).*(2*n+3)));



%% Optimization Method

% compute the right side for the weighted least squares
psi = S2Kernel(sqrt(psi.A).*(2*(0:psi.bandwidth)+1));
g = conv(f,psi);
WeightedFhat = g.fhat;

% Compute alternately optimal quadrature nodes and optimal quadrature weights
kMax = 100;
for k=1:kMax

  vNew = compactify(f,'points',v,'weights',c,varargin{:});

  % weights least squares problem  F^H * c = fhat  with  c>=0
  tol = 1e-13;
  maxit = 1000;
  [c,iter] = mlsq(@(x, transp_flag) afun(transp_flag, x, vNew, bw, lambda,psi),WeightedFhat, c, maxit, tol);
  if iter==maxit
    warning('mlsq:itermax','Maximum number of iterations reached, result may not have converged to the optimum yet.');
  end

  if max(angle(v,vNew)) < tol
    v = vNew;
    break;
  end

  % update
  v = vNew;

end
k



end

function y = afun(transp_flag, x, nodes, bw,lambda,psi)

if strcmp(transp_flag, 'notransp')

  F = S2FunHarmonic.adjoint(nodes,x,'bandwidth',bw);
  % F = S2FunHarmonic.adjoint(nodes,x,'keepPlan','bandwidth',bw,varargin{:});
  F = lambda * conv(F,psi);
  y = F.fhat;
  
elseif strcmp(transp_flag, 'transp')

  F = S2FunHarmonic(x);
  F.bandwidth = bw;
  F = lambda*conv(F,psi);

  % y = F.eval(nodes,'keepPlan',varargin{:});
  y = F.eval(nodes);

end

end