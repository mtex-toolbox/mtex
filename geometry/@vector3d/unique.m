function [v,m,n] = unique(v,varargin)
% disjoint list of vectors
%
%% Syntax
%   v = unique(v) % find disjoined elements of the vector v
%   [v,m,n] = unique(v,varargin)] %
%
%% Input
%  v - @vector3d
%
%% Output
%  v - @vector3d
%  m -
%  n -

x = v.x(:);
y = v.y(:);
z = v.z(:);

if check_option(varargin,'antipodal') || check_option(v,'antipodal')
  xyz = [x.^2,y.^2,z.^2,x.*y,x.*z,y.*z];  
else
  xyz = [x,y,z];  
end

% find duplicates points
[ignore,m,n] = unique(round(xyz*1e7),'rows'); %#ok<ASGLU>

% remove duplicated points
v.x = v.x(m);
v.y = v.y(m);
v.z = v.z(m);

%[v,ind] = cunion(v,@(a,b) eq(a,b,varargin{:}));

v = delete_option(v,'INDEXED');
