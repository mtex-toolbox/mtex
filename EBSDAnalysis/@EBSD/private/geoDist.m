function [d,src] = geoDist(seed, mask, stencil, szP, nSteps)
% number of stencil steps from seed to every cell of mask, inf beyond nSteps,
% and the seed cell they are counted from
d = inf(prod(szP),1); d(seed) = 0;
src = zeros(prod(szP),1); src(seed) = find(seed);
m = find(mask);
nb = m + (stencil(:,1) + stencil(:,2)*szP(1)).';
for k = 1:nSteps
  [hit,j] = max(d(nb) == k-1,[],2);
  hit = hit & isinf(d(m));
  if ~any(hit), break; end
  d(m(hit)) = k;
  src(m(hit)) = src(nb(find(hit) + (j(hit)-1)*numel(m)));
end
end
