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

% We have to decide which bandwidth we are using dependent from the
% oversampling factor.
% The same method is used in S2FunHarmonic/interpolate
function bw = chooseBandwidth(nodes, y, s, varargin)

bw = get_option(varargin,'bandwidth');
nSym = numSym(s.properGroup) * (isalmostreal(y)+1);

% assume there is some bandwidth given
if ~isempty(bw)
  % degrees of freedom in frequency space 
  numFreq = (bw+1)^2 / nSym;
  % TODO: False oversampling factor, see corrosion data example in paper (cubic symmetry)
  oversamplingFactor = length(nodes)/numFreq;
  if oversamplingFactor<1.9
    warning(['The oversampling factor in the approximation process is ', ...
      num2str(oversamplingFactor),'. This could lead to a bad approximation.'])
  end
  return
end

% Choose an fixed oversampling factor of 2
oversamplingFactor = 2;
bw = dim2deg(round( length(nodes)*nSym/oversamplingFactor ));

bw = min(bw,getMTEXpref('maxS2Bandwidth'));

end