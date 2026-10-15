function p = regionId(xyz)
%
% the plains x=abs(y),x=abs(z),y=abs(z) split the cube into 6 pyramids
% regionId takes a given vector of points of the cube and returns the
%   coresponding pyramid it lies in as a vector of numbers
% 
% Input : (n,3)-vector containing N points of the cube 
% Output: number (1,2,3,4,5,6) representing the pyramid the point lies in

p = ones(size(xyz,1),1);

p((abs(xyz(:,1))>=abs(xyz(:,3))) & (abs(xyz(:,3))>=abs(xyz(:,2)))) = 2;
p((abs(xyz(:,2))>=abs(xyz(:,1))) & (abs(xyz(:,1))>=abs(xyz(:,3)))) = 3;
p((abs(xyz(:,2))>=abs(xyz(:,3))) & (abs(xyz(:,3))>=abs(xyz(:,1)))) = 4;
p((abs(xyz(:,3))>=abs(xyz(:,1))) & (abs(xyz(:,1))>=abs(xyz(:,2)))) = 5;
p((abs(xyz(:,3))>=abs(xyz(:,2))) & (abs(xyz(:,2))>=abs(xyz(:,1)))) = 6;

end