function [m,hkl] = mean(hkl,varargin)
% mean of a list of Miller, principle axes and moments of inertia
%
% Syntax
%   [m, hkl] = mean(hkl)
%   [m, hkl] = mean(hkl,'robust')
%   [m, hkl] = mean(hkl,'weights',weights)
%
% Input
%  hkl      - list of @Miller
%
% Options
%  weights  - list of weights
%
% Output
%  m   - mean @Miller
%  hkl - crystallographic equivalent @direction projected to fundamental sector
%

persistent plan

% some cases where nothing is to do
if isempty(hkl)
  m.x = NaN; m.y = NaN; m.z = NaN;
  return
elseif length(hkl) == 1
  return;
elseif check_option(varargin,'noSymmetry')
  m = mean@vector3d(hkl,varargin{:});
  return
end

% get a first guess of the mean
if check_option(varargin,'m0')
  m = get_option(varargin,'m0');
  varargin = delete_option(varargin,'m0',1);
else
  m = hkl.subSet(find(~isnan(hkl.x),1));
end
  
% maybe the vectors are sufficiently concentrated around m
if all(angle(m,hkl) < 10*degree)
    
  hkl = project2FundamentalRegion(hkl,m);
  m = mean@vector3d(hkl,varargin{:});
  return
end

% In the general case we need a more robust algorithm

% lets start with a search grid in the fundamental sector  
% setting up the search grid takes some time
% hence we try to reuse the last one
if isempty(plan) || plan.CS ~= hkl.CS
  plan.CS = hkl.CS;
  sR = fundamentalSector(hkl.CS);
  plan.r = plotS2Grid(sR,'resolution',10*degree);
end

% compute for each point the mean square distance to all vectors
d = mean(angle_outer(hkl,plan.r).^2);

% take the minimum as the initial gues
[~,id] = min(d);
m = subSet(plan.r,id);

hkl = project2FundamentalRegion(hkl,m);
m = mean@vector3d(hkl,varargin{:});

if nargout == 2, hkl = project2FundamentalRegion(hkl,m); end
