function sF = interpolate(nodes, y, varargin)
% Interpolate an S2FunHarmonic by given function values at given points on
% the sphere.
%
% Let $M$ spherical points $v_i$ and corresponding function values $y_i$ be
% given. We compute the S2FunHarmonic $f$ of an specific bandwidth which 
% minimizes the least squares problem
%
% $$\sum_{i=1}^M|f(v_i)-y_i|^2.$$
%
%
% Syntax
%   sF = S2FunHarmonic.interpolate(nodes, val)
%   sF = S2FunHarmonic.interpolate(nodes, val, 'bandwidth', bandwidth, 'tol', TOL, 'maxit', MAXIT, 'weights', W)
%
% Input
%  nodes - @vector3d (grid on sphere)
%  val   - function values on the grid (may be multidimensional)
%
% Options
%  bandwidth  - maximum degree of the spherical harmonics used to approximate the function
%  tol        - tolerance for lsqr
%  maxit      - maximum number of iterations for lsqr
%  weights    - weight w_n for the node nodes (default: Voronoi weights)
%
% See also
% vector3d/interp S2VectorFieldHarmonic/interpolate

% make points unique
s = size(y);
y = reshape(y, length(nodes), []);
[nodes,~,ind] = unique(nodes(:));
y(isnan(y)) = 0;
% take the mean over duplicated nodes
for k = 1:size(y,2)
  yy(:,k) = accumarray(ind,y(:,k),[]) ./ accumarray(ind,1); %#ok<AGROW>
end

% consider the case of symmetry
if isa(nodes,'Miller')
  nodes = nodes.symmetrise('noAntipodal').';
  nodes.antipodal = nodes.CS.isLaue;
  yy = repmat(yy,size(nodes,2),1);
  nodes = nodes(:);
end

y = reshape(yy, [length(nodes) s(2:end)]);

% determine bandwidth && antipodal option
if check_option(varargin, 'antipodal') || nodes.antipodal
  nodes.antipodal = true;
  bw = get_option(varargin, 'bandwidth', ceil(sqrt(length(nodes))));
  bw = floor(bw/2)*2; % make bandwidth even
  mask = sparse((bw+1)^2); % only use even polynomial degree
  for m = 0:2:bw
    mask((m^2+1):(m^2+2*m+1), (m^2+1):(m^2+2*m+1)) = speye(2*m+1);
  end
else
  bw = get_option(varargin, 'bandwidth', ceil(sqrt(length(nodes)/2)));
  mask = 1;
end

% regularization options
lambda = get_option(varargin,{'regularization','regularisation','regularize','regularise'},0);
regularize = lambda > 0;
What = get_option(varargin,'fourier_weights');
if isempty(What) && regularize 
  SobolevIndex = get_option(varargin,'SobolevIndex',2);
  What = (2*(0:bw)+1).^(2*SobolevIndex);
  What = repelem(What,1:2:(2*bw+1))';
end

% get weights
W = get_option(varargin, 'weights');
if strcmp(W,'equal')
  W = 1/length(nodes);
elseif isempty(W) 
  W = calcVoronoiArea(nodes)/4/pi;
else
  W = W(ind);
end
W = sqrt(W(:));

b = W.*y;
if regularize
  b = [b;zeros((bw+1)^2,size(b,2))];
end

% get lsqr parameters
tol = get_option(varargin, 'tol', 1e-6);
maxit = get_option(varargin, 'maxit', 40);

% create plan
xi = S2FunHarmonic(0); xi.bandwidth=bw;
xi.eval(nodes,'createPlan');
S2FunHarmonic.adjoint(nodes,y(:,1),'createPlan','bandwidth',bw);

% least squares solution
for index = 1:size(y,2)
  [fhat(:, index), flag(index)] = lsqr(...
    @(x, transp_flag) afun(transp_flag, x, nodes, W, bw, mask, regularize, lambda, What, varargin), ...
    b(:, index), tol, maxit);
  fhat(:, index) = mask*fhat(:, index);
end
if any(flag == 1)
  warning('lsqr:itermax','Maximum number of iterations reached, result may not have converged to the optimum yet.');
end

% kill plan
S2FunHarmonic.adjoint(1,1,'killPlan');
S2FunHarmonic(1).eval(1,'killPlan');

sF = S2FunHarmonic(fhat);
sF.how2plot = getClass(varargin,'plottingConvention',nodes.how2plot);

% ensure symmetry if required
if isa(nodes,'Miller')
  sF = sF.symmetrise(nodes.CS); 
end

end

function y = afun(transp_flag, x, nodes, W, bw, mask, regularize, lambda, What, varargin)

if strcmp(transp_flag, 'transp')

  if regularize
    u = x(length(nodes)+1:end);
    x = x(1:length(nodes));
  end
  x = x .* W;
  % F = S2FunHarmonic.adjoint(nodes,x,'bandwidth',bw);
  F = S2FunHarmonic.adjoint(nodes,x,'keepPlan','bandwidth',bw);
  y = mask * F.fhat;
  if regularize
    y = y + u .* (sqrt(lambda)*sqrt(What));
  end

elseif strcmp(transp_flag, 'notransp')

  F = S2FunHarmonic(mask * x);
  F.bandwidth = bw;
  y = F.eval(nodes,'keepPlan');
  y = y .* W;
  if regularize
    y = [y;F.fhat .* (sqrt(lambda)*sqrt(What))];
  end

end

end
