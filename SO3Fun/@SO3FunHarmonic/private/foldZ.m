function [ind,s,x] = foldZ(k,r,x)
% keep the frequencies of one dimension of a Fourier array that are multiples of r
%
% Description
% A function with an r-fold rotational symmetry around the Z-axis only has
% Fourier coefficients at the frequencies k = r*k'. Its Fourier series in
% the angle x equals the series in k' at the node r*x, on an r times
% smaller lattice.
%
% Input
%  k - frequencies of the dimension
%  r - multiplicity of the symmetry
%  x - nodes in [-1/2,1/2) of the corresponding angle
%
% Output
%  ind - indices of the kept frequencies, which start at index 0 of the nfft
%  s   - shift of the kept frequencies against the centered ones of an
%        nfft of even length 2*ceil(numel(ind)/2)
%  x   - nodes r*x in [-1/2,1/2)
%

ind = find(mod(k,r) == 0);
s = k(ind(1))/r + ceil(numel(ind)/2);
if r > 1, x = mod(r*x + 0.5,1) - 0.5; end

end
