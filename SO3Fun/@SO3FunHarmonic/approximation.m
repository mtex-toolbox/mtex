function SO3F = approximation(nodes, y, varargin)
% computes a least square problem to get an approximation
%
% Syntax
%   SO3F = SO3FunHarmonic.approximation(SO3Grid, f)
%   SO3F = SO3FunHarmonic.approximation(SO3Grid, f,'constantWeights')
%   SO3F = SO3FunHarmonic.approximation(SO3Grid, f, 'bandwidth', bandwidth, 'tol', TOL, 'maxit', MAXIT, 'weights', W)
%
% Input
%  SO3Grid - rotational grid
%  f       - function values on the grid (maybe multidimensional)
%
% Options
%  constantWeights  - uses constant normalized weights (for example if the nodes are constructed by equispacedSO3Grid)
%  bandwidth        - maximum degree of the Wigner-D functions used to approximate the function
%  tol              - tolerance for lsqr
%  maxit            - maximum number of iterations for lsqr
%  weights          - weight w_n for the nodes (default: Voronoi weights)
%

if isa(nodes,'orientation')
  SRight = nodes.CS; SLeft = nodes.SS;
  if nodes.antipodal
    nodes.antipodal = 0;
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
  yy(:,k) = accumarray(ind,y(:,k),[],@nanmean); %#ok<AGROW>
end

y = reshape(yy, [length(nodes) s(2:end)]);

tol = get_option(varargin, 'tol', 1e-6);
maxit = get_option(varargin, 'maxit', 50);

% TODO: What bandwidth?
bw = get_option(varargin, 'bandwidth', min(dim2deg(length(nodes)*2),getMTEXpref('maxSO3Bandwidth')));

W = get_option(varargin, 'weights');
if check_option(varargin,'constantWeights')
  W = 1/length(nodes);
elseif isempty(W)
  % TODO: calcVoronoiVolume is bad estimated
  [~,i,~] = unique(quaternion(nodes));
  nodes=nodes(i); y=y(i,:);
  W = calcVoronoiVolume(nodes);
else
  W = accumarray(ind,W);
end

W = sqrt(W(:));


b = W.*y;

% create plan
% SO3FunHarmonic([1;1]).eval(nodes,'createPlan','nfsoft')
% SO3FunHarmonic.quadrature(nodes,1,'createPlan','nfsoft','bandwidth',bw)

% least squares solution
for index = 1:size(y,2)
  [fhat(:, index),flag] = lsqr( ...
    @(x, transp_flag) afun(transp_flag, x, nodes, W,bw), b(:, index), tol, maxit);
end

% kill plan
% SO3FunHarmonic.quadrature(1,'killPlan','nfsoft')
% SO3FunHarmonic(1).eval(1,'killPlan','nfsoft')

SO3F = SO3FunHarmonic(fhat,SRight,SLeft);     

end




function y = afun(transp_flag, x, nodes, W,bw)

if strcmp(transp_flag, 'transp')

  x = x.*W;
%   F = SO3FunHarmonic.quadrature(nodes,x,'keepPlan','nfsoft','bandwidth',bw);
  F = SO3FunHarmonic.quadrature(nodes,x,'bandwidth',bw);
  y = F.fhat;

elseif strcmp(transp_flag, 'notransp')

  F = SO3FunHarmonic(x,nodes.CS,nodes.SS);
  F.bandwidth = bw;
%   y = F.eval(nodes,'keepPlan','nfsoft');
  y = F.eval(nodes);
  y = y.*W;

end

end

% Possibly split the quadrature and eval functions. Therefore do the
% precomputations before the lsqr-Method.

% TODO: Try Cross-Vallidation, if there are to much points 
% TODO: Possibly use the Round2ClenshawCurtis-function (see quadrature) or delete it

