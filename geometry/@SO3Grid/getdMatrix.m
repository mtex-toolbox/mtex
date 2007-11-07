function M = getdMatrix(G,i)
% get precalculated distMatrix(G,G)

if nargin == 1, i = 1;end

if isempty(G(i).dMatrix)
  G(i).dMatrix = distMatrix(G(i),G(i),G(i).delta*2);
end

M = G(i).dMatrix;
