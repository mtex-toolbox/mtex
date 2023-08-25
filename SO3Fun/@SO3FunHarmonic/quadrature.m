function SO3F = quadrature(f, varargin)
% Compute the SO(3)-Fourier/Wigner coefficients of an given @SO3Fun or
% given evaluations on a specific quadrature grid.
%
% This method evaluates the given SO3Fun on an with respect to symmetries 
% fundamental Region. Afterwards it uses a inverse trivariate nfft/fft and
% an adjoint coefficient transform which is based on a representation
% property of Wigner-D functions.
% Hence it do not use the NFSOFT (which includes a fast polynom transform) 
% as in the older method |SO3FunHarmonic.quadratureNFSOFT|.
%
% Syntax
%   SO3F = SO3FunHarmonic.quadrature(nodes,values,'weights',w)
%   SO3F = SO3FunHarmonic.quadrature(f)
%   SO3F = SO3FunHarmonic.quadrature(f, 'bandwidth', bandwidth)
%
% Input
%  nodes  - @quadratureSO3Grid, @rotation, @orientation
%  values - double (first dimension has to be the evaluations)
%  f - function handle in @orientation (first dimension has to be the evaluations)
%
% Output
%  SO3F - @SO3FunHarmonic
%
% Options
%  bandwidth      - minimal harmonic degree (default: 64)
%
% See also
% SO3FunHarmonic/adjoint


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
SO3G = quadratureSO3Grid(bw,'ClenshawCurtis',SRight,SLeft,'ABG');
  
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
    LCM = lcm((1+double(round(2*pi/gMax/SRight.multiplicityZ) == 4))*SRight.multiplicityZ,SLeft.multiplicityZ);
    while mod(2*bw+2,LCM)~=0
      bw = bw+1;
    end
end
