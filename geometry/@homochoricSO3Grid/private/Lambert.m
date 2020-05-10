function xyz = Lambert(q)

% Lamert projection = volume preserving mapping from northern hemissphere
%   of S^3 to ball (radius (3*pi/4)^(1/3))
% maps unit quaternions (representing rotations) to points of the ball
%   (=homochoric representation)
%
% Input:    q   (dimension (N,4) array) - coordniates of N unit quaternions q
% Output:   xyz (dimension (N,3) array) - coordniates of N points (x,y,z) of the ball 

A = sqrt(1 - q(:,1).^2);
A(abs(A)<0.000001) = 1;
B = (3/2 * (acos(abs(q(:,1))) - abs(q(:,1)) .* A)).^(1/3);

xyz = B ./ A .* q(:,2:4);

end