function [m, v]  = mean(m,varargin)
% mean of a list of Miller, principle axes and moments of inertia
%
% Syntax
%   [m, v] = mean(hkl)
%   [m, v] = mean(hkl,'robust')
%   [m, v] = mean(hkl,'weights',weights)
%
% Input
%  hkl      - list of @Miller
%
% Options
%  weights  - list of weights
%
% Output
%  m      - mean @Miller
%  v      - crystallographic equivalent @direction projected to fundamental sector
%

% some cases where nothing is to do
if isempty(m)
  m.x = NaN; m.y = NaN; m.z = NaN;
  if nargout > 1, v = vector3d.nan;end
  return
elseif length(m) == 1
  if nargout > 1
    v = vector3d(m);
  end
  return;
end

% first approximation
if check_option(varargin,'noSymmetry')
  
  m = mean@vector3d(m,varargin{:});
  return
  
elseif check_option(varargin,'m0')
  
  m_mean = get_option(varargin,'m0',vector3d(m.subSet(find(~isnan(m.x),1))));
  m_mean = vector3d(project2FundamentalRegion(m_mean,m.CS));
  varargin = delete_option(varargin,'m0',1);
  
else
  
  r = plotS2Grid(m.CS.fundamentalSector,'resolution',10*degree);

  d = mean(angle_outer(m,r).^2);
  
  [~,id] = min(d);

  m_mean = r.subSet(id);

end

old_mean = [];
v = vector3d(m);
v.antipodal = false;

% iterate mean
iter = 1;
while iter < 5 && (isempty(old_mean) || (angle(dot(m_mean,old_mean))<0.1*degree))
  old_mean = m_mean;
  v = project2FundamentalRegion(v,m.CS,old_mean);
  m_mean = mean(v,varargin{:});
  
  iter = iter + 1;
end

v = reshape(v,size(m));

m.x = m_mean.x;
m.y = m_mean.y;
m.z = m_mean.z;
