function [v,m,n] = unique(v,varargin)
% disjoint list of vectors
%
% Syntax
%   v = unique(v) % find disjoined elements of the vector v
%   v = unique(v,'tolerance',0.01) % use tolerance 0.01
%   [v,m,n] = unique(v,varargin)] 
%    
%
% Input
%  v - @vector3d
%
% Output
%  v - @vector3d
%  m -
%  n -
%
% Option
%  stable - prevent sorting
%

x = v.x(:);
y = v.y(:);
z = v.z(:);

if check_option(varargin,'antipodal') || v.antipodal
  xyz = [x.^2,y.^2,z.^2,x.*y,x.*z,y.*z];  
else
  xyz = [x,y,z];  
end

tol = get_option(varargin,'tolerance',1e-7);

% in case it should not be sorted
if check_option(varargin,'stable')
  varargin = {'stable'};
else
  varargin= {};
end
% find duplicates points
try
  [~,m,n] = uniquetol(1+xyz,tol,'ByRows',true,varargin{:});
catch
  [~,m,n] = unique(round(xyz./tol),'rows',varargin{:});
end

% remove duplicated points
v.x = v.x(m);
v.y = v.y(m);
v.z = v.z(m);
