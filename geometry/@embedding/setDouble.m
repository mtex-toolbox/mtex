function E = setDouble(E,d)
% the embedding with the coordinates d, the inverse of double
%
% Syntax
%   E = setDouble(E,d)
%
% Input
%  E - @embedding
%  d - double, n x dim(E)
%
% Output
%  E - @embedding
%
% See also
% embedding/double

s = size(E);
d = E.B * reshape(d,[],size(E.B,2)).';
pos = cumsum([0 3.^E.rank(:).']);
for k = 1:numel(E.u)
  M = d(pos(k)+1:pos(k+1),:);
  if E.rank(k) == 1
    E.u{k} = vector3d(M(1,:),M(2,:),M(3,:));
  else
    E.u{k}.M = reshape(M,[3*ones(1,E.rank(k)) size(M,2)]);
  end
end
if prod(s) == size(d,2), E = reshape(E,s); end

end
