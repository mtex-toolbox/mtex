function f_hat = calcFourier(S2F,varargin)
% compute harmonic coefficients of S2FunMLS
%
% Syntax
%   f_hat = calcFourier(S2F)
%   f_hat = calcFourier(S2F,'bandwidth',L)
%
% Input
%  S2F - @S2FunMLS
%  L   - maximum harmonic degree
%
% Output
%  f_hat - harmonic coefficients
%
% Options
%  bandwidth - maximum harmonic degree, by default as many coefficients as
%              nodes, a real function counting twice
%
% Flags
%  ClenshawCurtis - quadrature on a Clenshaw Curtis instead of a Gauss Legendre grid
%
% See also
% S2FunHarmonic/quadrature S2FunHarmonic/interpolate

bw = get_option(varargin,'bandwidth');
if isempty(bw)
  bw = round(sqrt(length(S2F.nodes) * (isalmostreal(S2F.values)+1)) - 1);
  bw = min(bw,getMTEXpref('maxS2Bandwidth'));
end

if check_option(varargin,'ClenshawCurtis')
  S2F = S2FunHarmonic.quadrature(S2F,varargin{:},'bandwidth',bw);
else
  S2F = S2FunHarmonic.quadrature(S2F,varargin{:},'bandwidth',bw,'GaussLegendre');
end
f_hat = S2F.fhat;

end
