function q = getQuantile(x, p)

% linearly interpolated quantile of the finite entries of x
% only a single quantile is needed, so this avoids the Statistics Toolbox

x = sort(x(:));
x = x(isfinite(x));

if isempty(x), q = NaN; return; end
if isscalar(x), q = x; return; end

p = min(max(p, 0), 1);
pos = 1 + (numel(x) - 1) * p;
lo = floor(pos);
hi = ceil(pos);

if lo == hi
  q = x(lo);
else
  a = pos - lo;
  q = (1-a) * x(lo) + a * x(hi);
end

end
