function sF = quadrature(f, varargin)
% Compute the S2-Fourier/harmonic coefficients of an given @S2Fun or
% given evaluations on a specific quadrature grid.
%
% Therefore we obtain the Fourier coefficients with numerical integration
% (quadrature), i.e. we choose a quadrature scheme of meaningful quadrature 
% nodes $v_m$ and quadrature weights $\omega_m$ and compute
%
% $$ \hat f_n^{k} = \int_{S^2} f(v)\, \overline{Y_n^{k}(v)} \mathrm{d}\my(v) \approx \sum_{m=1}^M \omega_m \, f(v_m) \, \overline{Y_n^{k}(v_m)}, $$
%
% for all $n=0,\dots,N$ and $k=-n,\dots,n$. 
%
% Therefore this method evaluates the given S2Fun on the quadrature grid.
% Afterwards it uses the adjoint NFSFT (nonequispaced fast spherical 
% Fourier transform) to quickly compute the above sums.
%
% Syntax
%   sF = S2FunHarmonic.quadrature(nodes,values,'weights',w)
%   sF = S2FunHarmonic.quadrature(f)
%   sF = S2FunHarmonic.quadrature(f, 'bandwidth', bandwidth)
%   sF = S2FunHarmonic.quadrature(f, frame)
%
% Input
%  values - double (first dimension has to be the evaluations)
%  nodes  - @vector3d
%  f      - function handle in vector3d (first dimension has to be the evaluations)
%  frame  - @crystalFrame or @specimenFrame the result is written in
%
% Output
%  sF - @S2FunHarmonic
%
% Options
%  bandwidth - minimal degree of the spherical harmonic (default: 128)
%  symmetrise - spread the nodes or the function over the group first
%
% See also
% S2FunHarmonic/approximate S2FunHarmonic S2FunHarmonic/symmetrise

if isa(f,'vector3d')
  sF = S2FunHarmonic.adjoint(f,varargin{:});
  return
end

if isa(f,'function_handle')
  f = S2FunHandle(f,varargin{:});
elseif check_option(varargin,'symmetrise')
  f = S2FunHandle(@f.eval,varargin{:},f.frame);
end

if f.antipodal
  f.antipodal = false;
  varargin{end+1} = 'antipodal';
end

bw = get_option(varargin,'bandwidth', 128);

if check_option(varargin,'S2Grid')
  S2G = get_option(varargin,'S2Grid');
else
  S2G = quadratureS2Grid(bw,varargin{:});
end

% evaluate on the grid
values = f.eval(S2G);

% adjoined Fourier transform 
varargin = delete_option(varargin,'symmetrise');
sF = S2FunHarmonic.adjoint(S2G,values,'bandwidth',bw,varargin{:},f.frame);

end
