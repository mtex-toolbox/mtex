function [d,src] = geoDist(seed, mask, stencil, szP, nSteps)
% number of stencil steps from seed to every cell of mask, inf beyond nSteps,
% and the seed cell they are counted from
n = prod(szP);
d = inf(n,1); d(seed) = 0;
src = zeros(n,1); src(seed) = find(seed);
o = stencil(:,1) + stencil(:,2)*szP(1);
% the mask cells next to the seed
isSeed = d == 0; near = false(n,1);
for s = o.', a = max(1,1-s); b = min(n,n-s); near(a:b) = near(a:b) | isSeed(a+s:b+s); end
x = find(mask(:) & near & ~isSeed);
last = zeros(n,1);
for k = 1:nSteps
  if isempty(x), break; end
  d(x) = k;
  [~,j] = max(reshape(d(x + o.'),[],numel(o)) == k-1,[],2);
  src(x) = src(x + o(j));
  % the mask cells next to the new front are reached next, each taken once
  x = reshape(x - o.',[],1);
  x = x(mask(x) & isinf(d(x)));
  last(x) = 1:numel(x); x = x(last(x) == (1:numel(x)).');
end
end
