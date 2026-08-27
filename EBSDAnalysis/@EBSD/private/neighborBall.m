function offs = neighborBall(stencil, order)
% all integer lattice offsets reachable within `order` stencil-hops
%
% Generic replacement for the square-specific diamond mask
% (|i|+|j|<=order) and the hex-specific ring walk: works for any stencil
% (4 directions for square, 6 for hex) by a Minkowski-sum/BFS expansion,
% independent of the number of EBSD pixels.
%
% Input
%  stencil - k × 2 integer 1-hop neighbour offsets
%  order   - number of hops
%
% Output
%  offs - n × 2 integer offsets, graph-distance 1..order, excluding (0,0)

ball = zeros(1,2);
frontier = zeros(1,2);

for k = 1:order

  cand = reshape(permute(frontier,[1 3 2]) + permute(stencil,[3 1 2]),[],2);
  cand = setdiff(unique(cand,'rows'), ball, 'rows');
  if isempty(cand), break; end
  ball = [ball; cand]; %#ok<AGROW>
  frontier = cand;

end

offs = ball(any(ball~=0,2),:);

end
