function [chat,iter] = spatialMethod(SO3G,psi,nodes,y,varargin)
% Spatial-Solver for SO3FunRBF - Least Square Approximation Problem 
%
% Determine the coefficients (weights) of the SO3FunRBF $f$ with given kernel
% function psi and given center-orientations SO3G, such that it hold
% $f(nodes) \approx y$. 
% Hence we minimize the pointwise error (in spatial domain) of the
% SO3FunRBF $f$ at the orientations $nodes$ to the desired values $y$.
%
% Syntax
%   [chat,iter] = spatialMethod(SO3G,psi,nodes,y,varargin)
%
% Input
%  SO3G - @orientation  (center of the SO3FunRBF)
%  psi - @SO3Kernel  (kernel of the SO3FunRBF)
%  nodes - @orientation
%  y - double
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
%  LSQRMethod  -  ('lsqr'|'lsqlin'|'lsqnonneg'|'nnls'|'mlrl'|'mlsq')


% Use the 'mlsq'-method, if:
%   - an density is approximated
%   - the input is nearly positive and we have (or can easily compute) the expected mean of the result
eps = max(y(:))*1e-3;
if check_option(varargin,'density')
  varargin = ['mlsq',varargin];
elseif check_option(varargin,'mean') && (all(y(:)>-eps) || all(y(:)<eps))
  varargin = ['mlsq',varargin];
elseif numel(nodes)<1e4 && (all(y(:)>-eps) || all(y(:)<eps))
  W = calcVoronoiVolume(nodes);
  W = W./sum(W);
  meanV = sum(W(:).*y(:));
  varargin = ['mlsq','mean',meanV,varargin];
end


% Compute Kernel-matrix
Psi = createSummationMatrix(psi,SO3G,nodes,varargin{:});

switch get_flag(varargin,{'lsqr','lsqlin','lsqnonneg','nnls','mlrl','mlsq'},'lsqr')

  case 'lsqlin' % requires optimization Toolbox
      
    tolCon = get_option(varargin,'lsqlin_tolCon',1e-10);
    tolX = get_option(varargin,'lsqlin_tolX',1e-14);
    tolFun = get_option(varargin,'lsqlin_tolFun',1e-10);
    options = optimoptions('lsqlin','Algorithm','interior-point',...
      'Display','iter','TolCon',tolCon,'TolX',tolX,'TolFun',tolFun);
    n2 = size(Psi,1);
    chat = lsqlin(Psi',y(:),-eye(n2,n2),zeros(n2,1),[],[],[],[],[],options);
    
  case 'nnls' % only computable if Psi is small, i.e. low number of nodes and SO3Grid is small
    
    chat = nnls(full(Psi).',y(:),struct('Iter',1000));
    
  case 'lsqnonneg' % very slow / bad / maybe oscillating
    
    chat = lsqnonneg(Psi',y(:));
    
  case 'lsqr' % works good 
    
    itermax = get_option(varargin,'maxit',30);
    tol = get_option(varargin,'tol',1e-3);
    [chat,flag,~,iter] = lsqr(Psi',y(:),tol,itermax);
    if flag == 1
      warning('lsqr:maxit','Maximum number of iterations reached, result may not have converged to the optimum yet.');
    end
  
  case {'mlrl','mlsq'}  % we have constraints that c>0
    
    m = get_option(varargin,'mean',1.0);
    % initial guess for coefficients
    c0 = Psi*y(:);
    if check_option(varargin,'density')
      c0(c0<eps) = eps; % all weights must be positive
    else
      cx = abs(c0)<=eps;
      c0(cx) = sign(c0(cx))*eps;
    end
    c0 = m*c0./sum(c0(:));
    
    itermax = get_option(varargin,'maxit',100);
    tol = get_option(varargin,'tol',1e-3);
    
    if check_option(varargin,'mlrl')
      [chat,iter] = mlrl(Psi.',y(:),c0(:),itermax,tol/size(Psi,2)^2);  % --> Data have to be positive; dont works
    else
      [chat,iter] = mlsq(Psi.',y(:),c0(:),itermax,tol); % --> data should be positive; works nice 
    end
    
end

end
