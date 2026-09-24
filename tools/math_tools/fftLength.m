function n = fftLength(n)
% smallest even length >= n without prime factors above 13
%
% Description
% FFTW transforms such lengths fast, while a large prime factor, as in
% 388 = 4*97, can make the FFT several times slower than a slightly longer
% one.
%
% Syntax
%   n = fftLength(n)
%
% Input
%  n - minimum lengths
%
% Output
%  n - even integers without prime factors above 13
%

n = 2*ceil(n/2);
for i = 1:numel(n)
  while max(factor(n(i))) > 13, n(i) = n(i) + 2; end
end

end
