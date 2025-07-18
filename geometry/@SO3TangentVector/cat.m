function SO3TV = cat(dim,varargin)
% overloads cat of SO3TangentVectors (not vector3d)

[~,ind] = find(cellfun(@(v) isa(v,'SO3TangentVector'),varargin));
v = varargin{ind(1)};
r = [];
for i = ind(1:end)
  tS = ensureCompatibleTangentSpaces(v,varargin{i});
  v.tangentSpace = tS;
  r = cat(dim,r,varargin{i}.rot);
end

v = cat@vector3d(dim,varargin{:});
SO3TV = SO3TangentVector(v,r);

end
