function normals = faceNormals(gB3)
% computes normal vectors of each face
    normals = vector3d(meshFaceNormals(gB3.allV.xyz, gB3.poly))';
end