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
%
% Input
%  values - double (first dimension has to be the evaluations)
%  nodes - @vector3d
%  f - function handle in vector3d (first dimension has to be the evaluations)
%
% Output
%  sF - @S2FunHarmonic
%
% Options
%  bandwidth - minimal degree of the spherical harmonic (default: 128)
%
% See also
% S2FunHarmonic/approximate S2FunHarmonic

% --------------------- (1) Input is (nodes,values) -----------------------

if isa(f,'vector3d')
  sF = S2FunHarmonic.adjoint(f,varargin{:});
  return
end

% ---------- (2) Get nodes, values and weights in case of S2Fun ----------

if isa(f,'function_handle')
  sym = extractSym(varargin);
  f = S2FunHandle(f,sym);
end

if f.antipodal
  f.antipodal = 0;
  varargin{end+1} = 'antipodal';
end

bw = get_option(varargin,'bandwidth', 128);

if check_option(varargin,'S2Grid')
  S2G = get_option(varargin,'S2Grid');
else
  S2G = quadratureS2Grid(bw,varargin{:});
end

% evaluate on S2Grid
values = f.eval(S2G);
S2G.how2plot = getClass(varargin,'plottingConvention',S2G.how2plot);

% ----------------------- (3) Do adjoint NSOFT ----------------------------

sF = S2FunHarmonic.adjoint(S2G,values,varargin{:});
sF.bandwidth = bw;

% if antipodal consider only even coefficients
if check_option(varargin,'antipodal') || S2G.antipodal 
  sF = sF.even;
end
