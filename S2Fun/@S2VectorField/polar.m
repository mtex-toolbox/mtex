function [vF,vF2] = polar(rRef)
% reference vector field on the pole figure

if nargin == 0, rRef = xvector; end

vF = S2VectorFieldHandle(@(r) local(r));
vF2 = S2VectorFieldHandle(@(r) localOrth(r));

  function v = local(r)
    v = normalize(rRef - r);
    v = normalize(v - dot(v,r) .* r);
  end

  function v = localOrth(r)
    v = normalize(rRef - r);
    v = normalize(cross(r,v));
  end

end

