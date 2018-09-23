function omega = angularVelocityVector(L)
% angular velocity vector omega


omega = -0.5 .* vector3d(EinsteinSum(tensor.leviCivita,[1 -1 -2],L,[-1 -2]));
