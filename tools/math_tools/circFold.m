function y = circFold(x,f0,H)
% Fourier coefficients at the indices of an FFT of length H
%
% Description
% The entries of x of the frequencies f0(d), f0(d)+1, ... along dimension d go
% to the indices mod(frequency,H(d))+1, summed where they coincide. An FFT of
% the result is the sum of the coefficients at their frequencies, without a
% phase shift afterwards, and with the aliasing of a lattice too small for all
% of them.
%
% Syntax
%   y = circFold(x,f0,H)
%
% Input
%  x  - coefficients, up to 3 dimensions
%  f0 - frequency of the first entry along every dimension
%  H  - FFT length along every dimension
%
% Output
%  y - H(1) x H(2) x H(3)
%
n = size(x,1:3); H(end+1:3) = 1; f0(end+1:3) = 0;
idx = arrayfun(@(d) mod(f0(d)+(0:n(d)-1),H(d))+1,1:3,'UniformOutput',false);
y = zeros(H,'like',x);
if all(n <= H), y(idx{:}) = x; return, end
for a = 1:H(1):n(1), for b = 1:H(2):n(2), for c = 1:H(3):n(3)
  i = {a:min(a+H(1)-1,n(1)), b:min(b+H(2)-1,n(2)), c:min(c+H(3)-1,n(3))};
  y(idx{1}(i{1}),idx{2}(i{2}),idx{3}(i{3})) = y(idx{1}(i{1}),idx{2}(i{2}),idx{3}(i{3})) + x(i{:});
end, end, end
end
