function  oR = fundamentalRegion(cs,varargin)
% get the fundamental sector for a symmetry in the inverse pole figure
%
% Syntax
%   oR = fundamentalRegion(cs)
%   oR = fundamentalRegion(cs1,cs2)
%
% Input
%  cs,cs1,cs2 - @symmetry
%
% Ouput
%  sR - @orientationRegion
%
% Options
%  invSymmetry - wheter mori == inv(mori)
%

q = unique(quaternion(cs),'antipodal');
if nargin == 2 && isa(varargin{1},'symmetry')
  q = q * unique(quaternion(varargin{1}),'antipodal');
  dcs = disjoint(cs,varargin{1});
  N0 = rotation('axis',dcs.fundamentalSector.N,'angle',pi-1e-5);  
else
  N0 = quaternion;
end

% take +- minimal angles for each axis
q(abs(q.angle)<1e-5) = [];
axes = q.axis;

[axes,~,c] = unique(axes,'antipodal');
angles = zeros(size(axes));

for i = 1:length(axes)
  angles(i) = min(q(c==i).angle);
end

N = [axes;-axes];
Nq = axis2quat(N,pi-[angles;angles]/2);


oR = orientationRegion([Nq(:).',N0(:).']);
