function vF = polarField(rRef)
% compute and reference vector field on the pole figure

if nargin == 0, rRef = xvector; end

vF = S2VectorFieldHandle(@(r) local(r));

  function v = local(r)
    v = normalize(rRef - r);
    v = normalize(v - dot(v,r) .* r);
  end

end

