function [m,sigma] = nfftParameters(M,sz,varargin)
% window cutoff m and oversampling sigma of an nfft with M nodes on a lattice of size sz
%
% Description
% Both pairs hold the nfft error below 1e-8. With few nodes on a large
% lattice the FFT dominates and the small oversampling 1.25 pays for the
% longer window m = 6, with many nodes the window sums dominate and m = 4,
% sigma = 2 is faster. The window of m = 6 needs at least 32 points in every
% dimension, on a smaller one, e.g. folded by a 6-fold axis, it degenerates.
% The options 'cutoffParameter' and 'oversampling' override the choice.
%

if M < prod(sz)/4 && min(sz) >= 32, m = 6; sigma = 1.25; else, m = 4; sigma = 2; end
m = get_option(varargin,'cutoffParameter',m);
sigma = get_option(varargin,'oversampling',sigma);

end
