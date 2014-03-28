function v = volume(sR,varargin)
% volume of a spherical region
%
%
% formula: v = S - (n-2)*pi
% where S is the sum of the interior angles and n is the number of vertices

% TODO


%first only for triangles

l = [1,2,3];
r = [2,3,1];

innerAngles = angle(sR.N(l),sR.N(r));

v = sum(innerAngles) - length(sR.n-2) * pi;
