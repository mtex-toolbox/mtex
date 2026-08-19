function SO3TV = cat(dim,varargin)
% overloads cat of SO3TangentVectors (not vector3d)

[~,ind] = find(cellfun(@(v) isa(v,'SO3TangentVector'),varargin));
v = varargin{ind(1)};
tS = v.tangentSpace;
% the symmetry pair of the first element becomes the pair of the result -
% ensureCompatibleSymmetries below has established that they all agree. The
% references are concatenated bare, so no symmetry of a single element can
% leak into the pair of the whole
ref = v.oriRef;
cs = ref.CS;
ss = ref.SS;
r = [];

for i = ind(1:end)
  ensureCompatibleSymmetries(v,varargin{i})
  varargin{i} = transformTangentSpace(varargin{i},tS);
  r = cat(dim,r,rotation(varargin{i}.oriRef));
end

v = cat@vector3d(dim,varargin{:});
SO3TV = SO3TangentVector(v,orientation(r,cs,ss),tS);

end
