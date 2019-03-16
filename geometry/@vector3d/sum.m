function s = sum(v,varargin)
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
%  @vector3d

% apply sum to each coordinate
s = v; 
s.opt = struct; % clear options (espcially required for resolution)
s.x = sum(v.x,varargin{:});
s.y = sum(v.y,varargin{:});
s.z = sum(v.z,varargin{:});

s.isNormalized = false;