function  [oR,dcs,nSym] = fundamentalRegion(cs,varargin)
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
if nargin >= 2 && isa(varargin{1},'symmetry')
  q = unique(q * quaternion(varargin{1}),'antipodal');
  dcs = disjoint(cs.properGroup,varargin{1}.properGroup);
  if check_option(varargin,'antipodal')
    dcs = dcs.Laue;
  end
  sR = dcs.fundamentalSector(varargin{:});
  N0 = rotation('axis',sR.N,'angle',pi-1e-5);
else
  N0 = quaternion;
  dcs = cs.properGroup;
  if check_option(varargin,'antipodal'), dcs = dcs.Laue; end
end
nSym = length(q);

% take +- minimal angles for each axis
q(abs(q.angle)<1e-5) = [];
axes = q.axis;

[axes,~,c] = unique(axes);
angles = zeros(size(axes));

for i = 1:length(axes)
  angles(i) = min(angle(q(c==i)));
end

N = [axes;-axes];
if ~isempty(N)
  Nq = axis2quat(N,[pi-angles/2;angles/2]); 
else 
  Nq = quaternion;
end

oR = orientationRegion([Nq(:).',N0(:).'],varargin{:});
