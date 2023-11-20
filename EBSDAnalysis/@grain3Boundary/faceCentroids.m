function centroids = faceCentroids(gB3)
% computes centroid of each face
  centroids = vector3d(meshFaceCentroids(gB3.allV.xyz, gB3.poly))';
end