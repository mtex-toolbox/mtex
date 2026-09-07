function B = orbitBasis(u0,rank)
% orthonormal basis of the smallest rotation invariant subspace containing u0
%
% the three spin matrices generate the rotations, so the space is closed once
% the image of every basis vector under each of them lies in the span

S = cat(3,[0 0 0;0 0 -1;0 1 0],[0 0 1;0 0 0;-1 0 0],[0 -1 0;1 0 0;0 0 0]);
pos = cumsum([0 3.^rank(:).']);

B = zeros(numel(u0),0);
queue = u0(:);
while ~isempty(queue)
  w = queue(:,1); queue(:,1) = [];
  w = w - B*(B.'*w); w = w - B*(B.'*w);
  if norm(w) < 1e-6, continue; end
  B(:,end+1) = w ./ norm(w); %#ok<AGROW>
  for i = 1:3
    queue(:,end+1) = generator(B(:,end),S(:,:,i),rank,pos); %#ok<AGROW>
  end
end

end

function w = generator(w,S,rank,pos)
% the derivative of the rotation action along S, on every index of every block

for k = 1:numel(rank)
  v = w(pos(k)+1:pos(k+1)); g = 0;
  for d = 1:rank(k)
    g = g + reshape(pagemtimes(reshape(v,3^(d-1),3,[]),'none',S,'transpose'),[],1);
  end
  w(pos(k)+1:pos(k+1)) = g;
end

end
