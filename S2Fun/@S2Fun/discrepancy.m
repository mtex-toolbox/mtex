function res = discrepancy(sF,v,varargin)
% kernel discrepancy between a discrete sample and a spherical density
%
% Description
%
% |discrepancy| measures how well a list of directions $v_j$ with weights
% $c_j$ represents the density function $f$, by the squared distance
%
% $$ J(v,c) = \| \mu - f \|_{\psi}^2 = \sum_{n=1}^N \frac{4\pi A_n}{2n+1}
% \sum_{k=-n}^{n} | \hat{\mu}_n^{k} - \hat{f}_n^{k} |^2, \qquad
% \mu = \lambda \, \sum_{j=1}^M c_j \, \delta_{v_j}, \quad
% \lambda = \int_{S^2} f(v) \,dv, $$
%
% i.e. the functional <S2Fun.optimalSample.html |optimalSample|> minimizes.
% Here $A_n$ are the Legendre coefficients of the
% <S2RestrictedDistanceKernel.html restricted distance kernel> and $N$ is the
% |bandwidth| - only the harmonic degrees up to $N$ are compared, so state
% the one the sample is meant for.
%
% Degree 0 is left out. The restricted distance kernel is only conditionally
% positive definite, its coefficient of degree 0 being negative, and the
% weights are normalized to sum up to 1, which makes that degree vanish
% anyway.
%
% Scaling $f$ multiplies the result by $\lambda^2$, hence discrepancies are
% comparable only between samples of the same function.
%
% Give the same |bandwidth| the sample was optimized for. Above it nothing was
% optimized, and since a sample gains its accuracy up to |bandwidth| partly at
% the expense of the higher degrees, scoring beyond it ranks two samples by
% the part neither of them minimized.
%
% Syntax
%   res = discrepancy(sF,v)
%   res = discrepancy(sF,v,'weights',c)
%   res = discrepancy(sF,v,'bandwidth',64)
%
% Input
%  sF - @S2Fun
%  v  - @vector3d, the sampling points
%
% Output
%  res - double
%
% Options
%  weights   - weights of the sampling points (default = ones(M,1)/M)
%  bandwidth - harmonic degree to compare up to (default = the bandwidth of sF)
%
% See also
% S2Fun/optimalSample S2Fun/discreteSample S2RestrictedDistanceKernel

% a function without a bandwidth of its own is approximated as accurately as
% optimalSample does it by default
if isa(sF,'S2FunHarmonic'), bw = sF.bandwidth; else, bw = 128; end
bw = get_option(varargin,'bandwidth',bw);

sF = S2FunHarmonic(sF,'bandwidth',bw);
sF.bandwidth = bw;

M = numel(v);
c = get_option(varargin,'weights',ones(M,1)/M);
c = c(:);
if numel(c) ~= M
  error('The number of weights does not match the number of directions.')
end
if any(c<0)
  error('The weights have to be non negative.')
end
c = c/sum(c);

psi = S2RestrictedDistanceKernel(bw+1);

% for antipodal functions the odd degrees vanish anyway
if sF.antipodal, psi.A(2:2:end) = 0; end

w = zeros((bw+1)^2,1);
for l = 1:bw
  w(l^2+1:(l+1)^2) = sqrt( 4*pi * psi.A(l+1)/(2*l+1) );
end

% harmonic coefficients of the discrete measure mu, restore the bandwidth in
% case its highest degrees vanish
mu = S2FunHarmonic.adjointNFSFT(v(:),c,'bandwidth',bw);
mu.bandwidth = bw;

res = sum(abs(w.*(sum(sF) * mu.fhat - sF.fhat)).^2);

end
