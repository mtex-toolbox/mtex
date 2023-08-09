function v = sum(v,varargin)
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

% apply sum to each coordinate
v.x = sum(v.x,varargin{:});
v.y = sum(v.y,varargin{:});
v.z = sum(v.z,varargin{:});

if isfield(v.opt,'tangentSpace')
  tS = v.opt.tangentSpace;
  v.opt = struct;
  v.opt.tangentSpace = tS;
else
  v.opt = struct;
end
v.isNormalized = false;
