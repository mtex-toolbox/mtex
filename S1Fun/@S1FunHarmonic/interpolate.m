function S1F = interpolate(nodes,values,varargin)
% Approximate an S1FunHarmonic by given function values at given nodes 
% w.r.t. some noise.
%
% Syntax
%   S1F = S1FunHarmonic.interpolate(nodes,values,'weights',w)
%
% Input
%  values - double (first dimension has to be the evaluations)
%  nodes - double
%  w - weights
%
% Output
%  S1F - @S1FunHarmonic
%
% Options
%  bandwidth       - maximal harmonic degree (Be careful by setting the bandwidth by yourself, since it may yields undersampling)
%  weights         - corresponding to the nodes (default is 'equal': all nodes are weighted similar; 'Voronoi': Voronoi volumes; numeric array W: specific weights for every node)
%  tol             - tolerance as termination condition for lsqr
%  maxit           - maximum number of iterations as termination condition for lsqr
%  regularization  - the energy functional of the lsqr solver is regularized by the Sobolev norm of SO3F with regularization parameter lambda (default: 1e-4)(0: no regularization)
%  SobolevIndex    - for regularization (default = 2)
%
%


% --------------- (1) Input is Gaussian quadrature grid -------------------

% sort nodes
[nodes,ind] = sort(mod(nodes(:),2*pi));
values = reshape(values,length(nodes),[]);
values = values(ind,:);
weights = get_option(varargin,'weights',1/length(nodes));
if check_option(varargin,'weights') && length(weights)>1
  weights = weights(ind);
end

% check for Gaussian quadrature grid
if check_option(varargin,'Gaussian') || norm(nodes-(0:length(nodes)-1)/length(nodes)*2*pi)<eps
  S1F = S1FunHarmonic.adjoint(nodes,values,varargin{:},'weights',1/length(nodes));
  return
end

% ------------------------ (2) Get LSQR-Parameters ------------------------

% make nodes unique
[nodes,~,ind] = uniquetol(nodes(:),1e-6);
for k = 1:size(values,2)
  v(:,k) = accumarray(ind,values(:,k),[],@mean);
end
values = v;

% regularization options
lambda = get_option(varargin,'regularization',1e-5);
SobolevIndex = get_option(varargin,'SobolevIndex',2);
regularize = lambda > 0;

% decide bandwidth
bw = get_option(varargin,'bandwidth',min(round(length(nodes)/4),getMTEXpref('maxS1Bandwidth')));
oversamplingFactor = length(nodes)/(2*bw+1);
if oversamplingFactor<1.9 && get_option(varargin,'regularization',1)==0
  warning(['The oversampling factor in the approximation process is ', ...
    num2str(oversamplingFactor),'. This could lead to a bad approximation. ' ...
    'You may should not set the regularization parameter to 0 in the ' ...
    'approximation method.'])
end

% lsqr parameters
tol = get_option(varargin, 'tol', 1e-6);
maxit = get_option(varargin, 'maxit', 100);

% --------------------------- (3) LEAST SQUARES ---------------------------

weights = sqrt(weights);
b = weights.*values;
if regularize
  b = [b;zeros(2*bw+1,size(b,2))];
end

% least squares solution
for index = 1:size(values,2)
  [fhat(:, index),flag(index)] ...
    = lsqr( @(x, transp_flag) afun(transp_flag, x, nodes, weights, bw,regularize,lambda,SobolevIndex,varargin),...
    b(:, index), tol, maxit);
end
if any(flag == 1)
  warning('lsqr:itermax','Maximum number of iterations reached, result may not have converged to the optimum yet.');
end

% kill plan
% SO3FunHarmonic.quadrature(1,'killPlan','nfsoft')
% SO3FunHarmonic(1).eval(1,'killPlan','nfsoft')

S1F = S1FunHarmonic(fhat);

end

% ------------------------------ functions --------------------------------

function y = afun(transp_flag, x, nodes, W,bw,regularize,lambda,SobolevIndex,varargin)

if strcmp(transp_flag, 'transp')
  
  if regularize
    u = x(length(nodes)+1:end);
    x = x(1:length(nodes));
  end
  x = x .* W;
  F = S1FunHarmonic.adjoint(nodes,x,'bandwidth',bw);
  y = F.fhat;
  if regularize
    y = y + u .* (sqrt(lambda) * abs((-bw:bw).').^SobolevIndex);
  end
 
elseif strcmp(transp_flag, 'notransp')

  F = S1FunHarmonic(x);
  F.bandwidth = bw;
  y = F.eval(nodes);
  y = y .* W;
  if regularize
    u = x .* ( sqrt(lambda)  * abs((-bw:bw).').^SobolevIndex);
    y = [y;u];
  end

end

end