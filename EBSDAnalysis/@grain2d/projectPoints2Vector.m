function [p,px,py] = projectPoints2Vector(grains,v)
% project all grain boundary points to vector going through the center of a grain.
%
% Syntax
%
%   [p,px,py] = projectPoints2Vector(grains,v)
%
% Input:
%  grains   - @grain2d
%  v        - @vector3d, image plane components will be used
%
% Output:
%  p     - cell containing projection lengths for all boundary points
%  px    - cell containing projection point x coordinates
%  py    - cell containing projection point y coordinates
%
% Example:
% mtexdata testgrains
% v = caliper(grains(8),'shortest')
% p = projectPoints2Vector(grains(8),v)


if length(grains) ~= length(v), error('number of input must be identical'); end

V = grains.V;
poly = grains.poly;
ce= grains.centroid;

for i=1:length(grains)
    
    % get vertices
    Vg = V(poly{i},:);
    
    % center vertices
    Vg = [Vg(:,1)-ce(i,1) Vg(:,2)-ce(i,2)];
    
    a = v(i).y/v(i).x;
    b = -1;
    c = Vg(:,2) - Vg(:,1)*a;
    
    p{i} = (a*Vg(:,2) - b*Vg(:,1))./sqrt(a^2+b^2);
    px{i} = (-a*c)/(a^2+b^2);
    py{i} = (-b*c)/(a^2+b^2);
end
end