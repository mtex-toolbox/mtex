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

q = rotation(cs);
N0 = quaternion;
if nargin >= 2 && isa(varargin{1},'symmetry')
  
  q = q * rotation(varargin{1});
  q = q(~q.isImproper);
  q = quaternion(unique(q));
  
  if ~check_option(varargin,'ignoreCommonSymmetries')
    dcs = disjoint(cs,varargin{1});
    
    if check_option(varargin,'antipodal'), dcs = dcs.Laue; end
      
    sR = dcs.fundamentalSector(varargin{:});
        
    N0 = rotation('axis',sR.N,'angle',pi-1e-5);
  end
else  
  q = q(~q.isImproper);
  q = quaternion(unique(q));
  dcs = cs.properSubGroup;
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
