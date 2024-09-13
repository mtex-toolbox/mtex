function v = cumsum(v,varargin)
% cumulative sum of vector3d
%
% Syntax
%   cumsum(v)   % sum along the first non singular dimension
%   cumsum(v,d) % sum along dimension d
%
% Input
%  v - @vector3d 
%
% Output
%  v - @vector3d

% apply sum to each coordinate
v.x = cumsum(v.x,varargin{:});
v.y = cumsum(v.y,varargin{:});
v.z = cumsum(v.z,varargin{:});

v.opt = struct;
v.isNormalized = false;
