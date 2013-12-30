function [ind,boundary] = checkFundamentalRegion(ori,varargin)
% checks whether a orientation sits within the fundamental region
%
%% Input
%  ori - @orientation
%
%% Options
%  center - @quaternion / center of fundamental region
%
%% Output
%  ind    - indices of those orientations that are within the Fundamental region

% take the product of crystal and specimen symmetries
%qSS = quaternion(ori.SS);
%qCS = quaternion(ori.CS);
c_sym = quaternion(ori.CS * ori.SS);

% compute rotational axes and angles
axes = get(c_sym(2:end),'axis');
angles = get(c_sym(2:end),'angle');
angles = min(angles,2*pi-angles);

ind = angles < 1e-6;
angles(ind) = [];
axes(ind) = [];

% compute for each axes the minimum rotational angle
c_sym = quaternion;
while numel(axes)>0
  ind = dot(axes,axes(1),'antipodal') >= 1 - 1e-9;
  angle = min(angles(ind));
  
  c_sym = [c_sym,axis2quat(axes(1),angle/2)]; %#ok<AGROW>
  
  axes(ind) = [];
  angles(ind) = [];
end

% convert to rodrigues space
rq = Rodrigues(ori);
rc_sym = Rodrigues(c_sym); 

% find rotations in the fundamental region
ind = true(size(rq));
for i = 1:numel(rc_sym)
    
  d = rc_sym(i);
  nd = norm(d).^2;
    
  ind = ind & abs(dot(rq,d)) <= nd + 0.000001;
  
end

if ~check_option(varargin,'onlyAngle')
  sym = disjoint(ori.CS,ori.SS);
  
  h = Miller(vector3d(rq),sym);
  
  ind = ind & checkFundamentalRegion(h);
end
