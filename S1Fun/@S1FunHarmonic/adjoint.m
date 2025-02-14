function S1F = adjoint(nodes,values, varargin)
% Compute the adjoint SO(3)-Fourier/Wigner transform of given evaluations 
% on specific nodes, by adjoint trivariate nfft/fft.
%
% Syntax
%   S1F = S1FunHarmonic.adjoint(nodes,values)
%   S1F = S1FunHarmonic.adjoint(nodes,values,'bandwidth',128,'weights',w)
%
% Input
%  nodes  - double
%  values - double
%
% Output
%  S1F - @S1FunHarmonic
%
% Options
%  bandwidth - maximal harmonic degree
%  weights   - quadrature weights
%
% See also
% S1FunHarmonic/quadrature S1FunHarmonic/approximate
 

N = get_option(varargin,'bandwidth',getMTEXpref('maxS1Bandwidth'));

w = get_option(varargin,'weights',1);
values = w.*values;

sz = size(values);

if check_option(varargin,'Gaussian')
  % adjoint fft
  fhat = fftshift(ifft(values),1);
  fhat(1,:) = [];
else
  % adjoint nfft
  plan = nfft(1,2*N+2,length(nodes));
  plan.x = nodes(:)/(2*pi);

  fhat = zeros([2*N+1,sz(2:end)]);
  for k=1:prod(sz(2:end))
    plan.f = values(:,k);
    plan.nfft_adjoint;
    fhat(:,k) = plan.fhat(2:end);
  end
end

fhat = reshape(fhat,[2*N+1,sz(2:end)]);
S1F = S1FunHarmonic(fhat);

end