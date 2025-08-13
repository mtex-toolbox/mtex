function SO3TV = cat(dim,varargin)
% overloads cat of SO3TangentVectors (not vector3d)

[~,ind] = find(cellfun(@(v) isa(v,'SO3TangentVector'),varargin));
v = varargin{ind(1)};
tS = v.tangentSpace;
r = [];

for i = ind(1:end)

  % ensure compatible symmetries
  em = (v.hiddenCS ~= varargin{i}.hiddenCS) || (v.hiddenSS ~= varargin{i}.hiddenSS);
  if em
    error('The symmetries are not compatible. (Calculations with @SO3TangentVector''s needs suitable intern symmetries.)')
  end

  varargin{i} = transformTangentSpace(varargin{i},tS);
  r = cat(dim,r,varargin{i}.rot);

end

v = cat@vector3d(dim,varargin{:});
SO3TV = SO3TangentVector(v,r);

end
