function out = scatterProp(v,ind,sGrid,n)
% write a property onto the grid, keeping any channel dimension
%
% Syntax
%   out = scatterProp(v,ind,sGrid,n)
%
% Input
%  v     - the property as the source holds it: n x 1 or n x k from a list,
%          r x c or r x c x k if the source was already a grid
%  ind   - grid point each of the n measurements lands on
%  sGrid - [r c] of the grid being built
%  n     - number of measurements in the source
%
% Output
%  out   - r x c, or r x c x k for a multi channel property
%
% Description
% An ordinary property is one value per measurement and lands on the (r x c)
% matrix of the map. A multi channel one - a 5 diode forescatter image, an
% RGB image - has k values per measurement and lands on r x c x k, one plane
% per channel, which is the layout @dynProp indexes. Grid points with no
% measurement stay NaN.
%
% n has to be passed rather than read off size(v,1): gridify is also called
% on a map that is already a grid, whose properties are the (r x c) matrix,
% and there size(v,1) is the row count rather than the measurement count.
%
% See also
% EBSD/gridify dynProp

k = numel(v) / n;
v = reshape(v,n,k);

if isnumeric(v) || islogical(v)
  out = nan([sGrid k]);
else
  out = v.nan([sGrid k]);
end

% one channel at a time: ind addresses the map, and consecutive channel
% planes are prod(sGrid) apart in linear order
m = prod(sGrid);
ind = ind(:);
for c = 1:k
  out(ind + (c-1)*m) = v(:,c);
end

end
