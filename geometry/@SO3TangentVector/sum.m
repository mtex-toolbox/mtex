function s = sum(v,varargin)

s = sum@vector3d(v,varargin{:});
s.rot = normalize(sum(v.rot,varargin{:}));
ensureCompatibleTangentSpaces(v,s,'equal');

end