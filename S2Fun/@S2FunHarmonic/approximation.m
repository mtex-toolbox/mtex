function sF = approximation(nodes, y, varargin)
% computes a least square problem to get an approximation
% Syntax
%   sF = S2FunHarmonic.approximation(S2Grid, f)
%   sF = S2FunHarmonic.approximation(S2Grid, f, 'bandwidth', bandwidth, 'tol', TOL, 'maxit', MAXIT, 'weights', W)
%
% Input
%  S2Grid - grid on the sphere
%  f      - function values on the grid (may be multidimensional)
%
% Options
%  bandwidth  - maximum degree of the spherical harmonics used to approximate the function
%  to         - tolerance for lsqm
%  maxIt      - maximum number of iterations for lsqm
%  W          - weight w_n for the node nodes (default: voronoi weights)
%

% make points unique
s = size(y);
y = reshape(y, length(nodes), []);
[nodes,~,ind] = unique(nodes(:));

% take the mean over duplicated nodes
for k = 1:size(y,2)
  yy(:,k) = accumarray(ind,y(:,k),[],@nanmean); %#ok<AGROW>
end

% consider the case of symmetry
if isa(nodes,'Miller')
  
  nodes = nodes.symmetrise('noAntipodal').';
  nodes.antipodal = nodes.CS.isLaue;
  yy = repmat(yy,size(nodes,2),1);
  nodes = nodes(:);
  
end

y = reshape(yy, [length(nodes) s(2:end)]);

tol = get_option(nodes, 'tol', 1e-6);
maxit = get_option(varargin, 'maxit', 40);

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
  mask = speye((bw+1)^2);
end

W = get_option(varargin, 'weights');
if isempty(W) 
  W = nodes.calcVoronoiArea;
else
  W = W(ind);
end
W = sqrt(W(:));

% initialize nfsft
nfsftmex('precompute', bw, 1000, 1, 0);
plan = nfsftmex('init_advanced', bw, length(nodes), 1);
nfsftmex('set_x', plan, [nodes.rho'; nodes.theta']); % set vertices
nfsftmex('precompute_x', plan);

b = W.*y;

s = size(b);
b = reshape(b, s(1), []);
num = size(b, 2);

fhat = zeros((bw+1)^2, num);
for index = 1:num
  [fhat(:, index), flag] = lsqr(...
    @(x, transp_flag) afun(transp_flag, x, plan, W, mask), ...
    b(:, index), tol, maxit);
  fhat(:, index) = mask*fhat(:, index);
end
fhat = reshape(fhat, [(bw+1)^2 s(2:end)]);

% finalize nfsft
nfsftmex('finalize', plan);

sF = S2FunHarmonic(fhat);

% ensure symmetry if required
if isa(nodes,'Miller'), sF = sF.symmetrise(nodes.CS); end

end

function y = afun(transp_flag, x, plan, W, mask)

if strcmp(transp_flag, 'transp')

  x = x.*W;

  nfsftmex('set_f', plan, x);
  nfsftmex('adjoint', plan);
  y = nfsftmex('get_f_hat_linear', plan);

  y = mask*y;

elseif strcmp(transp_flag, 'notransp')

  x = mask*x;

  nfsftmex('set_f_hat_linear', plan, x);
  nfsftmex('trafo', plan);
  y = nfsftmex('get_f', plan);

  y = y.*W;

end

end
