function c = centroid(gB3)
% computes centroid of each face

if isnumeric(gB3.F)
   
  c = mean(gB3.allV(gB3.F),2);

else

  % for testing the code of matgeom - we are much faster
  % c = vector3d(meshFaceCentroids(gB3.allV.xyz, gB3.F))';
  
  % duplicate vertices according to their occurrence in the face
  F = gB3.F.';
  V = gB3.allV([F{:}]);
  faceSize = cellfun(@numel,F).';
  faceEnds = cumsum(faceSize);
  faceId = repelem(1:length(gB3.F),faceSize).';
  
  % first poor estimate
  c = accumarray(faceId,V) ./ faceSize;

  % center around this estimate - this ensures (0,0,0) is in the plane
  V = V - c(faceId);

  % compute normal directions
  N = normalize(cross(V(faceEnds-1),V(faceEnds)));

  % compute the area of the triangles between the edges an a potential
  % center (here (0,0,0) - but the center does not matter here)
  a = dot(cross(V(1:end-1),V(2:end)), N(faceId(1:end-1)),'noAntipodal');

  % centroid of each triangle weighted by its area
  aV = a .* (V(1:end-1)+V(2:end))./3;
  
  aV(faceEnds(1:end-1)) = 0;
  a(faceEnds(1:end-1)) = 0;

  % take the average over the triangle centroids and divide by the total area 
  c = c + accumarray(faceId(1:end-1),aV) ./ accumarray(faceId(1:end-1),a);

end

end