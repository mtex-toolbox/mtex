function [grainsR,rot] = rotate2Plane(grains)
  N=grains.N;
  Z=vector3d.Z;
  
  if norm(N)~=1
    N=1/norm(N)*N;
  end

  v=cross(N,Z);
  omega=acos(dot(Z,N)/(norm(Z)*norm(N)));


  if N.z<0
    omega=pi-omega;
  end

  rot=rotation.byAxisAngle(v,omega);

  grainsR=rot*grains;
end