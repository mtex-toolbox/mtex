function  [oR,dcs,nSym] = fundamentalRegion(cs,varargin)
% fundamental region in orientation space for a (pair) of symmetries 
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
%  antipodal  - wheter mori == inv(mori)
%  LaueGroup  - consider only Laue groups (default)
%  pointGroup - consider point groups
%

if ~check_option(varargin,'pointGroup'), cs = cs.properGroup; end

q = rotation(cs);
N0 = quaternion;
if nargin >= 2 && (isa(varargin{1},'symmetry')||isa(varargin{1},'rotation'))

  cs2 = varargin{1};
  varargin(1) = [];
  % in the usual setting we don't care about reflections
  if ~check_option(varargin,'pointGroup'), cs2 = cs2.properGroup; end
  
  q = rotation(cs2) * q;   
  q = q(~q.isImproper);
  q = unique(quaternion(q));
  
  if ~check_option(varargin,'ignoreCommonSymmetries')
    dcs = disjoint(cs,cs2);
    
    if check_option(varargin,'antipodal')
      dcs = dcs.Laue; 
    else
      dcs = dcs.properGroup;
    end
      
    sR = dcs.fundamentalSector(varargin{:});
        
    N0 = rotation('axis',sR.N,'angle',pi-1e-5);
  end
else
  q = q(~q.isImproper);
  q = quaternion(unique(q));
  dcs = cs.properSubGroup;
  if check_option(varargin,'antipodal'), dcs = dcs.Laue; end
  cs2 = {};
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
  Nq = axis2quat(N,[angles/2;pi-angles/2]);
else
  Nq = quaternion;
end

oR = orientationRegion([Nq(:).',N0(:).'],cs,cs2,varargin{:});
