function xyz = Lambert(q)

% Lamert projection = volume preserving mapping from northern hemissphere
%   of S^3 to ball (radius (3*pi/4)^(1/3))
% maps unit quaternions (representing rotations) to points of the ball
%   (=homochoric representation)
%
% Input:    q   (dimension (N,4) array) - coordniates of N unit quaternions q
% Output:   xyz (dimension (N,3) array) - coordniates of N points (x,y,z) of the ball 

% take the absolute value, because sometimes rounded quaternions get
% slightly too large real part, which causes complex numbers to occur in
% other functions

A = sqrt(abs(1 - q(:,1).^2));

% remedy rounding errors
q = min(q,1);
q = max(q,-1);
A(A<0.000001) = 0;

B = (3/2 * (acos(abs(q(:,1))) - abs(q(:,1)) .* A)).^(1/3);

xyz = B ./ A .* q(:,2:4) .* sign(q(:,1));

% remove NaN entries (division by zero in step before)
xyz(A==0,:) = ones(sum(A==0),1) * [0,0,0];

end