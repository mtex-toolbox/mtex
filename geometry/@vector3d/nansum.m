function v = nansum(v,varargin)
% sum of vectors
%
% Syntax
%   sum(v)   % sum along the first non singular dimension
%   sum(v,d) % sum along dimension d
%
% Input
%  v - @vector3d 
%
% Output
%  v - @vector3d

% remove all nans
ind = isnan(v.z);
v.x(ind) = 0;
v.y(ind) = 0;
v.z(ind) = 0;

% apply sum to each coordinate
v.x = sum(v.x,varargin{:});
v.y = sum(v.y,varargin{:});
v.z = sum(v.z,varargin{:});

v.opt = struct;
v.isNormalized = false;
