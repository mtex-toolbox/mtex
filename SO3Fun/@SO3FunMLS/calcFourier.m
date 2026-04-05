function f_hat = calcFourier(SO3F,varargin)
% compute harmonic coefficients of SO3FunMLS
%
% Syntax
%   f_hat = calcFourier(SO3F)
%   f_hat = calcFourier(SO3F,'bandwidth',L)
%
% Input
%  SO3F - @SO3FunMLS
%  L    - maximum harmonic degree
%
% Output
%  f_hat - harmonic/Fourier/Wigner-D coefficients
%

% decide bandwidth
bw = chooseBandwidth(SO3F.nodes,SO3F.values,SO3F.SRight,SO3F.SLeft,varargin{:});

if check_option(varargin,'ClenshawCurtis')
  SO3F = SO3FunHarmonic.quadrature(SO3F,varargin{:},'bandwidth',bw);
else
  SO3F = SO3FunHarmonic.quadrature(SO3F,varargin{:},'bandwidth',bw,'GaussLegendre');
end
f_hat = SO3F.fhat;

end

% We have to decide which bandwidth we are using dependent from the
% oversampling factor.
% The same method is used in SO3FunHarmonic/interpolate
function bw = chooseBandwidth(nodes,y,SRight,SLeft,varargin)

bw = get_option(varargin,'bandwidth');
nSym = numSym(SRight.properGroup)*numSym(SLeft.properGroup)*(isalmostreal(y)+1);

% choose bandwidth such that   number of nodes = number of harmonic coefficients
if isempty(bw)
  bw = dim2deg(round( length(nodes)*nSym )); 
  bw = min(bw,getMTEXpref('maxSO3Bandwidth'));
end

end