function v = round2zero(v,varargin)
% set very small x,y,z values to zero

wasNormalized = v.isNormalized || all(norm(v)==1);
s = size(v);

if all(abs(v.x)<1e-6), v.x = zeros(s); end
if all(abs(v.y)<1e-6), v.y = zeros(s); end
if all(abs(v.z)<1e-6), v.z = zeros(s); end

if wasNormalized, v = v.normalize; end
