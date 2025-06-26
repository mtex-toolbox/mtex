function m = mean(v,varargin)

m = mean@vector3d(v,varargin{:});
m.rot = normalize(sum(v.rot,varargin{:}));
ensureCompatibleTangentSpaces(v,m,'equal');

end