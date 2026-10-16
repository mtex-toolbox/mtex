function [G,basisAtCenters] = localBasis(F,v,centerId,gridId)
% basis values at the neighbors, one row each, and at the centers

[pts,radial] = F.basisPoints(v,centerId,gridId);
G = F.evalBasis(pts);

% an odd basis changes sign between antipodal representatives
if F.antipodal && mod(F.degree,2) == 1
  G(radial < 0,:) = -G(radial < 0,:);
end

% in centered coordinates every center is the local origin
if F.centered
  basisAtCenters = F.evalBasis(F.localOrigin);
else
  basisAtCenters = F.evalBasis(v);
end

end
