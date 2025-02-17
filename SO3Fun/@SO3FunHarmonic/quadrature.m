function SO3F = quadrature(f, varargin)
% Compute the SO(3)-Fourier/Wigner coefficients of an given @SO3Fun or
% given evaluations on a specific quadrature grid.
%
% Therefore we obtain the Fourier coefficients with numerical integration
% (quadrature), i.e. we choose a quadrature scheme of meaningful quadrature 
% nodes $R_m$ and quadrature weights $\omega_m$ and compute
%
% $$ \hat f_n^{k,l} = \int_{SO(3)} f(R)\, \overline{D_n^{k,l}(R)} \mathrm{d}\my(R) \approx \sum_{m=1}^M \omega_m \, f(R_m) \, \overline{D_n^{k,l}(R_m)}, $$
%
% for all $n=0,\dots,N$ and $k,l=-n,\dots,n$. 
%
% Therefore this method evaluates the given SO3Fun on a with respect to 
% symmetries fundamental Region. Afterwards it uses a inverse trivariate 
% nfft/fft and an adjoint coefficient (Wigner) transform which is based on 
% a representation property of Wigner-D functions.
%
% Hence it do not use the NFSOFT (which includes a fast polynom transform) 
% as in the older method |SO3FunHarmonic.quadratureNFSOFT|.
%
% Syntax
%   SO3F = SO3FunHarmonic.quadrature(f)
%   SO3F = SO3FunHarmonic.quadrature(f,'bandwidth',bandwidth)
%   SO3F = SO3FunHarmonic.quadrature(f,'bandwidth',bandwidth,quadratureScheme)
%   SO3F = SO3FunHarmonic.quadrature(f,'bandwidth',bandwidth,'SO3Grid',S3G,'weights',w)
%   SO3F = SO3FunHarmonic.quadrature(nodes,values)
%   SO3F = SO3FunHarmonic.quadrature(nodes,values,'bandwidth',48,'weights',w)
%
% Input
%  f      - @SO3Fun, function_handle in @orientation (first dimension has to be the evaluations)
%  nodes  - @quadratureSO3Grid, @rotation, @orientation
%  values - double (first dimension has to be the evaluations)
%
% Output
%  SO3F - @SO3FunHarmonic
%
% Options
%  bandwidth - maximal harmonic degree (default: 64)
%  weights   - quadrature weights
%  SO3Grid   - quadrature nodes
%
% Flags
%  quadratureScheme - ('ClenshawCurtis'|'GaussLegendre') --> default: CC
%
% See also
% SO3FunHarmonic/adjoint SO3FunHarmonic/approximate SO3FunHarmonic


% Tests
% check_SO3FunHarmonicQuadrature


% --------------------- (1) Input is (nodes,values) -----------------------

if isa(f,'rotation')
  SO3F = SO3FunHarmonic.adjoint(f,varargin{:});
  return
end

% ---------- (2) Get nodes, values and weights in case of SO3Fun ----------

if isa(f,'function_handle')
  [SRight,SLeft] = extractSym(varargin);
  f = SO3FunHandle(f,SRight,SLeft);
end

if f.antipodal
  f.antipodal = 0;
  varargin{end+1} = 'antipodal';
end

N = get_option(varargin,'bandwidth', min(getMTEXpref('maxSO3Bandwidth'),f.bandwidth));

SRight = f.SRight; SLeft = f.SLeft;
  
% Use crystal and specimen symmetries by only evaluating at Clenshaw 
% Curtis quadrature grid in fundamental region. 
% Therefore adjust the bandwidth to crystal and specimen symmetry.
bw = adjustBandwidth(N,SRight,SLeft);
if check_option('SO3Grid')
  SO3G = get_option(varargin,'SO3Grid');
elseif check_option(varargin,'GaussLegendre')
  SO3G = quadratureSO3Grid(bw,'GaussLegendre',SRight,SLeft,'ABG');
else
  SO3G = quadratureSO3Grid(bw,'ClenshawCurtis',SRight,SLeft,'ABG');
end

% Only evaluate unique orientations
values = f.eval(SO3G);
  
% ----------------------- (3) Do adjoint NSOFT ----------------------------

SO3F = SO3FunHarmonic.adjoint(SO3G,values,varargin{:});
SO3F.bandwidth = N;

% if antipodal consider only even coefficients
SO3F.antipodal = check_option(varargin,'antipodal');

end





% --------------------------- functions -----------------------------------

function bw = adjustBandwidth(bw,SRight,SLeft)

[~,~,gMax] = fundamentalRegionEuler(SRight,SLeft,'ABG');
LCM = lcm((1+double(round(2*pi/gMax/SRight.multiplicityZ) == 4)) * ...
  SRight.multiplicityZ, SLeft.multiplicityZ);
while mod(2*bw+2,LCM)~=0
  bw = bw+1;
end

end
