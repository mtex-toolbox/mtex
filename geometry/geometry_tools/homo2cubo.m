function vCubo = homo2cubo(vHomo) 
% homochoric to cubochoric coordinates  
%
% Transforms homochoric coordinates of quaternions into cubochoric
% coordinates. This mpas the ball of radius (3*pi/4)^(1/3)) to the cube
% with edge length pi^(2/3).
% 
% Input
%  xyz - homochoric coordinates (x,y,z) of N points of the ball 
%
% Output
%  XYZ - cubochoric coordinates (X,Y,Z) of N points of the cube 
% 

% the actual mapping is only defined on one pyramid Pz (z>=abs(x),z>=abs(y)) 
% map other points by: 
%  1. transform coordinates, so that we get a point of Pz
%  2. map the point 
%  3. apply the inverse transformation 

% for each point find out, which pyramid it lies in (1,2,3,4,5,6)
rId = cuboRegionId(vHomo);         

% define permutaions (and inverse ones) for each region (pyramid)
permRegion  = [2 3 1; 3 2 1; 1 3 2; 3 1 2; 1 2 3; 2 1 3]; 
ipermRegion = [3 1 2; 3 2 1; 1 3 2; 2 3 1; 1 2 3; 2 1 3];

% apply the permutation on each row
vHomo = vHomo(sub2ind(size(vHomo), ...
  (1:size(vHomo,1)).' * [1 1 1] ,permRegion(rId,:)));

% map each point 
p = sqrt(sum(vHomo.^2,2));
D = sqrt(2 ./ (1 + abs(vHomo(:,3)) ./ p));
E = sqrt(2 * vHomo(:,1).^2 + vHomo(:,2).^2);
F = sqrt(abs(vHomo(:,1)) + E);
G = sign(vHomo(:,1));
H = sqrt(pi / 12);
I = (6 / pi)^(1/6);
K = D .* sqrt(E) .* F .* I;

vCubo(:,1) = K .* G .* H;
vCubo(:,2) = K ./ H .* (G .* atan(vHomo(:,2)./vHomo(:,1)) - atan(vHomo(:,2)./E));
vCubo(:,3) = sign(vHomo(:,3)) .* p ./ I^2;

% overwrite points with division by zero (occurs along the axes)
isNull = (vHomo(:,1)==0);
vCubo(isNull,:) = vHomo(isNull,:) / (6/pi)^(1/3);

% apply the inverse permutations 
vCubo = vCubo(sub2ind(size(vCubo), ...
  (1:size(vCubo,1)).' * [1 1 1] , ipermRegion(rId,:)));

end
