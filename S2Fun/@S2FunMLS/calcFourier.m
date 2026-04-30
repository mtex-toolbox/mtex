function f_hat = calcFourier(S2F,varargin)
% compute harmonic coefficients of S2FunMLS
%
% Syntax
%   f_hat = calcFourier(S2F)
%   f_hat = calcFourier(S2F,'bandwidth',L)
%
% Input
%  S2F - @S2FunMLS
%  L    - maximum harmonic degree
%
% Output
%  f_hat - harmonic/Fourier/Wigner-D coefficients
%

% decide bandwidth
bw = chooseBandwidth(S2F.nodes, S2F.values, S2F.s, varargin{:});

if check_option(varargin,'ClenshawCurtis')
  S2F = S2FunHarmonic.quadrature(S2F,varargin{:},'bandwidth',bw);
else
  S2F = S2FunHarmonic.quadrature(S2F,varargin{:},'bandwidth',bw,'GaussLegendre');
end
f_hat = S2F.fhat;

end


% decide for bandwith depending on the oversampling factor
%   (same as in S2FunHarmonic/interpolate)
function bw = chooseBandwidth(nodes, y, s, varargin)

bw = get_option(varargin,'bandwidth');
nSym = numSym(s.properGroup) * (isalmostreal(y)+1);

% Choose a fixed oversampling factor of 2
if isempty(bw)
  bw = round(sqrt( length(nodes)*nSym )-1);
  bw = min(bw,getMTEXpref('maxS2Bandwidth'));
end

end