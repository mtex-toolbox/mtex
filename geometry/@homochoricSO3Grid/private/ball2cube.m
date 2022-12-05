function XYZ = ball2cube(xyz) 
%
% transforms the homochoric representation of quaternions into cubochric 
% maps from the ball (radius (3*pi/4)^(1/3)) to the cube (edge pi^(2/3)) 
% 
% Input
%  xyz - homochoric coordinates (x,y,z) of N points of the ball 
%
% Output
%  sXYZ - cubochoric coordinates (X,Y,Z) of N points of the cube 
% 

% the actual mapping is only defined on one pyramid Pz (z>=abs(x),z>=abs(y)) 
% map other points by: 
%  1. transform coordinates, so that we get a point of Pz
%  2. map the point 
%  3. apply the inverse transformation 

% for each point find out, which pyramid it lies in (1,2,3,4,5,6)
p = regionId(xyz);         

% define permutaions (and inverse ones) for each region (pyramid)
permRegion  = [2 3 1;3 2 1;1 3 2;3 1 2;1 2 3;2 1 3]; 
ipermRegion = [3 1 2;3 2 1;1 3 2;2 3 1;1 2 3;2 1 3];

%  permxyz contains for each point its permutation 
% ipermxyz contains for each point its inverse permutation 

permxyz  =  permRegion(p,:);
ipermxyz = ipermRegion(p,:);

% apply the permutation on each grid point
xyz = xyz(sub2ind(size(xyz), (1:size(xyz,1)).' * [1 1 1] ,permxyz));

% map each point 
p = sqrt(xyz(:,1).^2 + xyz(:,2).^2 + xyz(:,3).^2);
D = sqrt(2 ./ (1 + abs(xyz(:,3)) ./ p));
E = sqrt(2 * xyz(:,1).^2 + xyz(:,2).^2);
F = sqrt(abs(xyz(:,1)) + E);
G = sign(xyz(:,1));
H = sqrt(pi / 12);
I = (6 / pi)^(1/6);
K = D .* sqrt(E) .* F .* I;

XYZ(:,1) = K .* G .* H;
XYZ(:,2) = K ./ H .* (G .* atan(xyz(:,2)./xyz(:,1)) - atan(xyz(:,2)./E));
XYZ(:,3) = sign(xyz(:,3)) .* p ./ I^2;

% overwrite points with division by zero (occurs along the axes)
O = (xyz(:,1)==0);
XYZ(O,:) = xyz(O,:) / (6/pi)^(1/3);

% apply the inverse permutations 
XYZ = XYZ(sub2ind(size(XYZ), (1:size(XYZ,1)).' * [1 1 1] ,ipermxyz));

end 