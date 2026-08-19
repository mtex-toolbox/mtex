function [v,iv,iu] = unique(v,varargin)
%

ensureCompatibleTangentSpaces(v,v,'AllEqual')
[v,iv,iu] = unique@vector3d(v,varargin{:});
v.oriRef = v.oriRef(iv);

end