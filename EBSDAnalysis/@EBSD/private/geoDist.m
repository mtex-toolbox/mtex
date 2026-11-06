function [d,src] = geoDist(seed, mask, stencil, szP, nSteps)
% number of stencil steps from seed to every cell of mask, inf beyond nSteps,
% and the seed cell they are counted from
d = inf(prod(szP),1); d(seed) = 0;
src = zeros(prod(szP),1); src(seed) = find(seed);
o = stencil(:,1) + stencil(:,2)*szP(1);
x = find(mask);
for k = 1:nSteps
  [hit,j] = max(reshape(d(x + o.'),[],numel(o)) == k-1,[],2);
  hit = hit & isinf(d(x));
  x = x(hit);
  if isempty(x), break; end
  d(x) = k;
  src(x) = src(x + o(j(hit)));
  % only the mask cells next to the new front can be reached next
  x = unique(reshape(x - o.',[],1));
  x = x(mask(x) & isinf(d(x)));
end
end
