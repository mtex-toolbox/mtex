function c = sampleWeights(M,varargin)
% the weights of M sampling points, as a probability distribution
%
% Syntax
%   c = sampleWeights(M)
%   c = sampleWeights(M,'weights',c)
%
% Input
%  M - number of points
%
% Output
%  c - M × 1, non negative, summing up to 1 - equal when none are given
%
% See also
% S2Fun/optimalSample S2Fun/discrepancy SO3Fun/optimalSample

c = get_option(varargin,'weights',ones(M,1)/M);
c = c(:);

assert(numel(c) == M,'The number of weights does not match the number of points.')
assert(all(c >= 0),'The weights have to be non negative.')

c = c/sum(c);

end
