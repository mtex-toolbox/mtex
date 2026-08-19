function n = multiplicityZ(cs)
% order of the symmetry axis along Z
%
% The result is cached on the symmetry: computing it builds the rotation
% axes of the entire group, while the Wigner transform asks for it once per
% call. symmetry/set.rot drops the cache whenever the group elements change.

if ~isempty(cs.multiplicityZRef), n = cs.multiplicityZRef; return; end

isZ = isnull(1-abs(dot(cs.rot.axis,zvector))) & ~isnull(cs.rot.angle);

if any(isZ(:))
  n = round(2*pi/min(abs(angle(cs.rot(isZ)))));
else
  n = 1;
end

cs.multiplicityZRef = n;
