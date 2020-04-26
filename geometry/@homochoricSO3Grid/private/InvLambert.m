function q = InvLambert(xyz)

% Inverse Lambert Projection 
% maps points of the ball with radius (3*pi/4)^(1/3) onto the 3-hemissphere
% this is the transformtaion of homochoric representation of rotations into
%   the representation as unit quaternions 
% function is an approximization with error <= ~10^(-7)
% 
% Input:   xyz (dimension (N,3) array) - coordniates of N points (x,y,z) of the ball 
% Output:  q   (dimension (N,4) array) - coordniates of N unit quaternions q


p = zeros(size(xyz,1),1);
p(:) = sqrt(xyz(:,1).^2 + xyz(:,2).^2 + xyz(:,3).^2);   

a = 1:7;
a(1) = -0.500009615;
a(2) = -0.024866061;
a(3) = -0.004549382;
a(4) = 0.000511867;
a(5) = -0.001650083;
a(6) = 0.000759335;
a(7) = -0.000204042;

t = ones(size(xyz,1),1);

for i=1:7
    t = t + a(1,i) * p.^(2*i);
end

A = 1 ./ sqrt(1 - t.^2);
B = acos(t) - t ./ A;

LambertFactor = ones(size(t));
LambertFactor = A .* ( 3/2 * B).^(1/3);
LambertFactor(abs(t-1)<0.00001) = 1;
LambertFactor(abs(LambertFactor)<0.00001) = 0;

q    = [t(:),xyz ./ LambertFactor];

end