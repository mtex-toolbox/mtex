function SO3F = approximation(nodes, y, varargin)
% approximate an SO3FunHarmonic by given function values at given nodes 
% w.r.t. some noise.
%
% For $M$ given orientations $R_i$ and corresponding function values $y_i$ 
% we compute the SO3FunHarmonic $f$ of an specific bandwidth which 
% minimizes the least squares problem
%
% $$\sum_{i=1}^M|f(R_i)-y_i|^2.$$
%
% If the oversampling factor is small (high bandwidth) it may be necessary
% to assure decay of the harmonic coefficents. Therefore we regularize the
% least squares problem by the Sobolev norm of f, i.e we minimize
%
% $$\sum_{i=1}^M|f(R_i)-y_i|^2 + \lambda \|f\|^2_{H^s}$$
%
% where $\lambda$ is the regularization parameter and $s$ the Sobolev
% index. The Sobolev norm of an SO3FunHarmonic with harmonic coefficients 
% $\hat{f}$ reads as
%
% $$\|f\|^2_{H^s} = \sum_{n=0}^N (2n+1)^{2s} \, \sum_{k,l=-n}^n|\hat{f}_n^{k,l}|^2.$$
%
% Syntax
%   SO3F = SO3FunHarmonic.approximation(SO3Grid, f)
%   SO3F = SO3FunHarmonic.approximation(SO3Grid, f,'constantWeights')
%   SO3F = SO3FunHarmonic.approximation(SO3Grid, f, 'bandwidth', bandwidth, 'tol', TOL, 'maxit', MAXIT, 'weights', W)
%   SO3F = SO3FunHarmonic.approximation(SO3Grid, f, 'regularization')
%   SO3F = SO3FunHarmonic.approximation(SO3Grid, f, 'regularization',0.1,'SobolevIndex',1)
%
% Input
%  SO3Grid - rotational grid
%  f       - function values on the grid (maybe multidimensional)
%
% Options
%  constantWeights  - uses constant normalized weights (for example if the nodes are constructed by equispacedSO3Grid)
%  weights          - weight w_n for the nodes (default: Voronoi weights)
%  bandwidth        - maximum degree of the Wigner-D functions used to approximate the function (Be careful by setting the bandwidth by yourself, since it may yields undersampling)
%  tol              - tolerance for lsqr
%  maxit            - maximum number of iterations for lsqr
%  regularization   - the energy functional of the lsqr solver is regularized by the Sobolev norm of SO3F (there is given a regularization constant)
%  SobolevIndex     - for regularization (default = 2)
%
% See also
% SO3Fun/interpolate SO3FunHarmonic/quadrature
% SO3VectorFieldHarmonic/approximation


nodes = nodes(:);
y = reshape(y,length(nodes),[]);

if isa(nodes,'orientation')
  SRight = nodes.CS; SLeft = nodes.SS;
  if nodes.antipodal
    nodes.antipodal = 0;
    nodes = [nodes(:);inv(nodes)];
    y = [y;y];
    varargin{end+1} = 'antipodal';
  end
else
  [SRight,SLeft] = extractSym(varargin);
  nodes = orientation(nodes,SRight,SLeft);
end

% make points unique
s = size(y);
y = reshape(y, length(nodes), []);
[nodes,~,ind] = unique(nodes(:),'tolerance',0.02);

% take the mean over duplicated nodes
for k = 1:size(y,2)
  yy(:,k) = accumarray(ind,y(:,k),[],@mean); %#ok<AGROW>
end

y = reshape(yy, [length(nodes) s(2:end)]);

tol = get_option(varargin, 'tol', 1e-6);
maxit = get_option(varargin, 'maxit', 50);

% decide bandwidth
[bw,varargin] = chooseBandwidth(nodes,y,SRight,SLeft,varargin{:});

% decide whether to use regularization
regularize = 0; lambda=0; SobolevIndex=0;
if check_option(varargin,'regularization')
  regularize = 1;
  lambda = get_option(varargin,'regularization',0.0001);
  if ~isnumeric(lambda), lambda = 0.0001; end
  SobolevIndex = get_option(varargin,'SobolevIndex',2);
  warning(['The least squares approximation is regularized with ' ...
    'regularization parameter lambda ', num2str(lambda), ...
    ' and Sobolev norm of Sobolev index ', num2str(SobolevIndex),'.'])
end

% extract weights
W = get_option(varargin, 'weights');
if check_option(varargin,'constantWeights')
  W = 1/length(nodes);
elseif isempty(W)
  W = calcVoronoiVolume(nodes);
else
  if length(W)>1, W = accumarray(ind,W); end
end
W = sqrt(W(:));

b = W.*y;
if regularize
  b = [b;zeros(deg2dim(bw+1),size(b,2))];
end

% create plan
% SO3FunHarmonic([1;1]).eval(nodes,'createPlan','nfsoft')
% SO3FunHarmonic.quadrature(nodes,1,'createPlan','nfsoft','bandwidth',bw)

% least squares solution
for index = 1:size(y,2)
  [fhat(:, index),flag] = lsqr( ...
    @(x, transp_flag) afun(transp_flag, x, nodes, W,bw,regularize,lambda,SobolevIndex), b(:, index), tol, maxit);
end

% kill plan
% SO3FunHarmonic.quadrature(1,'killPlan','nfsoft')
% SO3FunHarmonic(1).eval(1,'killPlan','nfsoft')

SO3F = SO3FunHarmonic(fhat,SRight,SLeft);     

end




function y = afun(transp_flag, x, nodes, W,bw,regularize,lambda,SobolevIndex)

if strcmp(transp_flag, 'transp')
  
  if regularize
    u = x(length(nodes)+1:end);
    x = x(1:length(nodes));
  end
  x = x .* W;
  %   F = SO3FunHarmonic.quadrature(nodes,x,'keepPlan','nfsoft','bandwidth',bw);
  F = SO3FunHarmonic.adjoint(nodes,x,'bandwidth',bw);
  y = F.fhat;
  if regularize
    F = SO3FunHarmonic(u);
    SO3F = conv(F,sqrt(lambda)*(2*(0:bw)+1).'.^SobolevIndex);
    y = y+SO3F.fhat;
  end

elseif strcmp(transp_flag, 'notransp')

  F = SO3FunHarmonic(x,nodes.CS,nodes.SS);
  F.bandwidth = bw;
  %   y = F.eval(nodes,'keepPlan','nfsoft');
  y = F.eval(nodes);
  y = y .* W;
  if regularize
    SO3F = conv(F,sqrt(lambda)*(2*(0:bw)+1).'.^SobolevIndex);
    y = [y;SO3F.fhat];
  end

end

end


% We have to decide which bandwidth we are using dependent from the
% oversampling factor and whether we are doing regularization or not.
function [bw,varargin] = chooseBandwidth(nodes,y,SRight,SLeft,varargin)

bw = get_option(varargin,'bandwidth');
nSym = numSym(SRight.properGroup)*numSym(SLeft.properGroup)*(isalmostreal(y)+1);

% assume there is some bandwidth given
if ~isempty(bw)
  % degrees of freedom in frequency space 
  numFreq = deg2dim(bw+1)/nSym;
  oversamplingFactor = length(nodes)/numFreq;
  if oversamplingFactor<1.9 && ~check_option(varargin,'regularization')
    warning(['The oversampling factor in the approximation process is ', ...
      num2str(oversamplingFactor),'. This could lead to a bad approximation. ' ...
      'You may should use the option ''regularization'' in the option list of the ' ...
      'approximation method.'])
  end
  return
end

% Choose an fixed oversampling factor of 2
oversamplingFactor = 2;
bw = dim2deg(round( length(nodes)*nSym/oversamplingFactor ));

% TODO: Choose higher bandwidth, ov=0.5 and regularization if bw is to small
if bw < 25
  oversamplingFactor = 0.5;
  bw = dim2deg(round( length(nodes)*nSym/oversamplingFactor ));
  varargin{end+1} = 'regularization';
end

bw = min(bw,getMTEXpref('maxSO3Bandwidth'));

end





% Possibly split the quadrature and eval functions. Therefore do the
% precomputations before the lsqr-Method.

% TODO: Try Cross-Vallidation, if there are to much points 

