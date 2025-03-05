function [chat,iter] = harmonicMethod(SO3G,psi,fhat,y,varargin)
% Harmonic-Solver for SO3FunRBF - Least Square Approximation Problem 
%
% Determine the coefficients (weights) of the SO3FunRBF $g$ with given kernel
% function psi and given center-orientations SO3G, such that it hold
% $\hat g \approx fhat$. 
% Hence we minimize the error (in frequency domain) of the Fourier
% coefficients ofthe SO3FunRBF $g$ to the desired Fourier coefficients 
% $fhat$.
%
% Syntax
%   [chat,iter] = harmonicMethod(SO3G,psi,fhat,y,varargin)
%
% Input
%  SO3G - @orientation  (center of the SO3FunRBF)
%  psi - @SO3Kernel  (kernel of the SO3FunRBF)
%  fhat - double
%  y - double  (initial values for chat)
%
% Output
%  chat - double  (weights of the SO3FunRBF)
%  iter - double  (number of lsqr iterations)
%
% Options
%  tol              - tolerance as termination condition for lsqr/mlsq/...
%  maxit            - maximum number of iterations as termination condition for lsqr/mlsq/...
%
% Flags
%  'density'
%  LSQRMethod  -  ('lsqr'|'mlrl'|'mlsq')
%

% Multidim. Vector Fields
sz = [1,1];
if numel(SO3G)~=numel(y(:))
  sz = size(fhat); sz = [sz(2:end),1];
end
y = reshape(y,numel(SO3G),[]);

% Use the 'mlsq'-method, if:
%   - an density is approximated
%   - the input is nearly positive and we have (or can easily compute) the expected mean of the result
eps = max(y(:))*1e-3;
if check_option(varargin,'density')
  varargin = ['mlsq',varargin];
elseif check_option(varargin,'mean') && (all(y(:)>-eps) || all(y(:)<eps))
  varargin = ['mlsq',varargin];
elseif numel(SO3G)<1e4 && (all(y(:)>-eps) || all(y(:)<eps))
  W = calcVoronoiVolume(SO3G);
  W = W./sum(W);
  meanV = sum(W(:).*y);
  varargin = ['mlsq','mean',meanV,varargin];
end

bw = psi.bandwidth;

%% LSQR - Solver

if ~check_option(varargin,'mlsq')
  
  itermax = get_option(varargin,'maxit',30);
  tol = get_option(varargin,'tol',1e-3);

  if deg2dim(psi.bandwidth+1)*length(SO3G)*8 < 0.5*2^30 % use direct computation

    % get fourier coefficients for each node
    a = zeros(deg2dim(bw+1),1);
    for i=0:bw
      a(deg2dim(i)+1:deg2dim(i+1)) = psi.A(i+1)/sqrt(2*i+1);
    end
    Fstar = WignerD(SO3G,'bandwidth',bw).*a;

    % sparsify
    Fstar(abs(Fstar) < 10*eps) = 0;
    Fstar = sparse(Fstar);

    % least squares
    for Index=1:prod(sz)
      [chat(:,Index),flag,~,iter] = lsqr(conj(Fstar),fhat(:,Index),tol,itermax);
    end

  else % use NFFT-based matrix-vector multiplication

    % get weights
    W = zeros(deg2dim(bw+1),1);
    for i=0:bw
      W(deg2dim(i)+1:deg2dim(i+1)) = psi.A(i+1)/(2*i+1);
    end

    % least squares
    for Index=1:prod(sz)
      [chat(:,Index),flag,~,iter] = lsqr( @(x, transp_flag) afun(transp_flag, x, SO3G(:), W, bw), fhat(:,Index), tol, itermax);
    end

  end

  if flag == 1
    warning('lsqr:maxit','Maximum number of iterations reached, result may not have converged to the optimum yet.');
  end

  chat = reshape(chat,[numel(SO3G) sz]);

  return

end



%% MLSQ - Solver

% initial guess for coefficients
m = get_option(varargin,'mean',1.0);
if length(m)<prod(sz)
  m = ones(sz)*m;
end

c0 = y ; %odf.eval(SO3G);
c0(c0<=eps) = eps;
c0 = reshape(m,[1 sz]).*c0./sum(c0,1);

itermax = get_option(varargin,'maxit',100);
tol = get_option(varargin,'tol',1e-3);

if deg2dim(psi.bandwidth+1)*length(SO3G)*8 < 0.5*2^30 % use direct computation

  % get fourier coefficients for each node
  a = zeros(deg2dim(bw+1),1);
  for i=0:bw
    a(deg2dim(i)+1:deg2dim(i+1)) = psi.A(i+1)/sqrt(2*i+1);
  end
  Fstar = WignerD(SO3G,'bandwidth',bw).*a;
  
  % sparsify
  Fstar(abs(Fstar) < 10*eps) = 0;
  Fstar = sparse(Fstar);
  
  % modified least squares
  for Index=1:prod(sz)
    [chat(:,Index),iter] = mlsq(conj(Fstar),fhat(:,Index),c0(:,Index),itermax,tol);
  end
  
else % use NFFT-based matrix-vector multiplication
  
  % get weights
  W = zeros(deg2dim(bw+1),1);
  for i=0:bw
    W(deg2dim(i)+1:deg2dim(i+1)) = psi.A(i+1)/(2*i+1);
  end
  
  % modified least squares
  for Index=1:prod(sz)
    [chat(:,Index),iter] = mlsq( @(x, transp_flag) afun(transp_flag, x, SO3G(:), W, bw), fhat(:,Index),c0(:,Index),itermax,tol);
  end

end

chat = reshape(chat,[numel(SO3G) sz]);

end

function y = afun(transp_flag, x, nodes, W, bw)

if strcmp(transp_flag, 'transp')
  
  x = x .* W;
  F = SO3FunHarmonic(x,nodes.CS,nodes.SS);
  F.bandwidth = bw;
  y = F.eval(nodes);
  
elseif strcmp(transp_flag, 'notransp')
  
  F = SO3FunHarmonic.adjoint(nodes,x,'bandwidth',bw);
  y = F.fhat;
  y = y .* W;
end

end
