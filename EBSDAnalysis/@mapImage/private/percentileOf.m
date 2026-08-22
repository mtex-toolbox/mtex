function v = percentileOf(x,p)
% percentiles of a sample, without the Statistics Toolbox
%
% The same convention prctile uses: the sorted values sit at the midpoints
% (i-0.5)/n of the cumulative distribution, linear in between, and flat
% outside the outermost of them.
%
% Syntax
%
%   v = percentileOf(x,[2 98])
%
% Input
%  x - values, any shape, NaN ignored
%  p - percentages in [0,100]
%
% Output
%  v - one value per entry of p
%
% See also
% mapImage/edgeMap

x = sort(x(:));
x = x(~isnan(x));

n = numel(x);

if n == 0
  v = nan(size(p));
elseif n == 1
  v = repmat(x,size(p));
else
  q = 100*((1:n).' - 0.5)/n;
  v = interp1(q,x,p(:),'linear');
  v(p(:) <= q(1)) = x(1);
  v(p(:) >= q(end)) = x(end);
  v = reshape(v,size(p));
end

end
