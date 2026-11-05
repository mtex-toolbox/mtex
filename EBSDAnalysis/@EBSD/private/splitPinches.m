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
isJoin = isfield(out,'inFill') && ~isempty(out.inFill);

for v = find(isP).'
  % the four segments at v counterclockwise, the first two around one cell
  e = find(any(F(1:nF,:) == v,2) & nC > 0);
  u = V(sum(F(e,:),2) - v,:) - V(v,:);
  [~,o] = sort(atan2(u(:,2),u(:,1)));
  if c(e(o(1))) ~= c(e(o(2))), o = circshift(o,-1); end
  e = e(o); u = u(o,:) ./ vecnorm(u(o,:),2,2);

  n = size(V,1) + 1;
  if isJoin && out.inFill(V(v,:)) > out.epsilon
    keep = [2 3]; move = [4 1];
    F(end+1,:) = [v n]; %#ok<AGROW>
    I_FD(end+1,[c(e(1)) c(e(3))]) = 1; %#ok<AGROW>
  else
    keep = [1 2]; move = [3 4];
  end
  w = sum(u(move,:)); V(n,:) = V(v,:) + out.dxy/4 * w ./ norm(w);
  w = sum(u(keep,:)); V(v,:) = V(v,:) + out.dxy/4 * w ./ norm(w);
  F(e(move),:) = F(e(move),:) + (F(e(move),:) == v) * (n - v);
end
