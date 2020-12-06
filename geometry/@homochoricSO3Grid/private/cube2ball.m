function xyz = cube2ball(XYZ)
%
% transforms cubochoric coordinates of quaternions into homochoric ones 
% maps from cube (edge pi^(2/3) onto ball (radius (3*pi/4)^(1/3)) 
% 
% Input
%  XYZ - cubochoric coordinates (X,Y,Z) of N points of the cube
%
% Output
%  xyz - homochoric coordinates (x,y,z) of N points of the ball 

% the actual mapping is only defined on one pyramid Pz (z>=abs(x),z>=abs(y)) 
% map other points by: 
%  1. transform coordinates, so that we get a point of Pz
%  2. map the point 
%  3. apply the inverse transformation 

% define permutaions (and inverse ones) for each region (pyramid)
p = regionId(XYZ);
permRegion  = [2 3 1;3 2 1;1 3 2;3 1 2;1 2 3;2 1 3]; 
ipermRegion = [3 1 2;3 2 1;1 3 2;2 3 1;1 2 3;2 1 3];

%  permXYZ contains for each point its permutation 
% ipermXYZ contains for each point its inverse permutation

permXYZ  =  permRegion(p,:);
ipermXYZ = ipermRegion(p,:);

% apply the permutation on each grid point
XYZ = XYZ(sub2ind(size(XYZ), (1:size(XYZ,1)).' * [1 1 1] ,permXYZ));

% map each point 
cosyx = sqrt(2) * cos(pi/12 * XYZ(:,2)./XYZ(:,1));
sinyx = sqrt(2) * sin(pi/12 * XYZ(:,2)./XYZ(:,1));

A = 2 * cosyx - 3;
B = 2 - cosyx;
C = (6/pi)^(1/3);
D = sqrt(A .* (XYZ(:,1).^2 - XYZ(:,3).^2) + XYZ(:,3).^2);
E = C * XYZ(:,1)./abs(XYZ(:,3)) .* D ./ B;

xyz = XYZ;
xyz(:,1) = E .* (cosyx - 1);
xyz(:,2) = E .* sinyx;
xyz(:,3) = C * (XYZ(:,3) + XYZ(:,1).^2 ./ XYZ(:,3) .* A ./ B);

% overwrite points with division by zero
O = (XYZ(:,1)==0);
xyz(O,:) = (6/pi)^(1/3) * XYZ(O,:);

xyz = xyz(sub2ind(size(xyz), (1:size(xyz,1)).' * [1 1 1] ,ipermXYZ));

end