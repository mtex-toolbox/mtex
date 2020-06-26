function d = dot(rot1,rot2,varargin)
% compute rot1 . rot2

d = dot@quaternion(rot1,rot2);

if ~check_option(varargin,'noAntipodal'), d = abs(d); end

try i1 = rot1.i; catch, i1 = false(size(rot1.a)); end
try i2 = rot2.i; catch, i2 = false(size(rot2.a)); end

d = d .* (~xor(i1,i2));
