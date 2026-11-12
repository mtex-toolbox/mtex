function [V,F,I_FD] = splitPinches(V,F,I_FD,out)
% split the vertices where the outer boundary touches itself
%
% Description
% Four outer boundary segments meeting in one vertex, a tie of the Voronoi
% decomposition on the lattice, let two cells touch in a single point. Such a
% vertex is split in two, half a pixel apart. Inside the filled cells the two
% cells then share the segment between the new vertices, elsewhere the
% outside passes between them.
%
% Input / Output
%  V,F,I_FD - vertices, segments and the incidence segments to cells
%  out      - output of spatialDecompositionGrid, for inFill, epsilon and dxy

[f,d] = find(I_FD);
nF = size(F,1); nV = size(V,1);
c = accumarray(f,d,[nF 1],@max);
nC = accumarray(f,1,[nF 1]);
isP = accumarray(reshape(F(nC > 0,:),[],1),1,[nV 1]) == 4 & ...
  accumarray(reshape(F(nC == 1,:),[],1),1,[nV 1]) == 4;
% the four segments at every pinch, a column per pinch in vertex order
s = find(nC > 0); m = isP(F(s,:)); P = F(s,:); E = [s s];
[~,o] = sortrows([P(m) E(m)]); E = E(m); E = reshape(E(o),4,[]);
v = find(isP); nP = numel(v);
inside = false(nP,1);
if ~isempty(out.inFill), inside = out.inFill(V(v,:)) > out.epsilon; end
V = [V; zeros(nP,2)]; J = zeros(nP,2);

for k = 1:nP
  % the four segments at v counterclockwise, the first two around one cell
  e = E(:,k);
  u = V(sum(F(e,:),2) - v(k),:) - V(v(k),:);
  [~,o] = sort(atan2(u(:,2),u(:,1)));
  if c(e(o(1))) ~= c(e(o(2))), o = circshift(o,-1); end
  e = e(o); u = u(o,:) ./ vecnorm(u(o,:),2,2);

  n = nV + k;
  if inside(k)
    keep = [2 3]; move = [4 1];
    J(k,:) = [c(e(1)) c(e(3))];
  else
    keep = [1 2]; move = [3 4];
  end
  w = sum(u(move,:)); V(n,:) = V(v(k),:) + out.dxy/4 * w ./ norm(w);
  w = sum(u(keep,:)); V(v(k),:) = V(v(k),:) + out.dxy/4 * w ./ norm(w);
  F(e(move),:) = F(e(move),:) + (F(e(move),:) == v(k)) * (n - v(k));
end

% a join inside the filled cells is a segment of the two cells across it
F = [F; v(inside), nV + find(inside)];
J = J(inside,:); nJ = size(J,1);
I_FD = [I_FD; sparse([1:nJ 1:nJ],J(:),1,nJ,size(I_FD,2)) > 0];
