function sF = regularisation(nodes,y,lambda,varargin)
% computes a regularisation
% Syntax
%   sF = S2FunHarmonic.regularisation(S2Grid,f,lambda)
%   sF = S2FunHarmonic.regularisation(S2Grid,f,lambda,'bandwidth',
%        bandwidth,'node_weights',W,'fourier_weights',What)
%
% Input
%  S2Grid - grid on the sphere
%  f      - function values on the grid (may be multidimensional)
%  lambda - parameter for regularisation
%
% Options
%  bandwidth  - maximum harmonic degree
%  W          - weight w_n for the node nodes (default: Voronoi weights)
%  What       - weight what_{m,l} for the Fourier space (default Sobolev weights for s = 2)
%

[nodes,idx] = unique(nodes(:));
y = reshape(y(idx),length(nodes),[]);
N = length(nodes);
W = get_option(varargin,'node_weights');
if isempty(W) 
  W = nodes.calcVoronoiArea;
end
bw = get_option(varargin,'bandwidth',floor(sqrt(2*pi/mean(W))));

What = get_option(varargin,'fourier_weights');
if isempty(What) 
  s = 2;
  What = (2*(0:bw)+1).^(2*s);
  What = repelem(What,1:2:(2*bw+1))';
end

% initialize nfsft
nfsftmex('precompute',bw,1000,1,0);
plan = nfsftmex('init_advanced',bw,N,1);
nfsftmex('set_x',plan,[nodes.rho';nodes.theta']);
nfsftmex('precompute_x',plan);

y = W.*y;

% adjoint nfsft
nfsftmex('set_f',plan, y);
nfsftmex('adjoint',plan);
fhat = nfsftmex('get_f_hat_linear',plan);

[fhat,~] = pcg(@(x) afun(x,plan,lambda,W,What),fhat);

sF = S2FunHarmonic(fhat);

% finalize nfsft
nfsftmex('finalize',plan);

end



function y = afun(x,plan,lambda,W,What)
  nfsftmex('set_f_hat_linear',plan,x);
  nfsftmex('trafo',plan);
  y = nfsftmex('get_f',plan);

  y = W.*y;

  nfsftmex('set_f',plan,y);
  nfsftmex('adjoint',plan);
  y = nfsftmex('get_f_hat_linear',plan);

  y = y+lambda*What.*x;
end