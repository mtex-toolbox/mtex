function v = accumarray(subs,v,varargin)
% accumarray for vector3d
%
% Syntax
%   v = accumarray(subs,v)   
%
% Input
%  subs - 
%  v - @vwector3d 
%
% Output
%  @vector3d

v.x = accumarray(subs,v.x,varargin{:});
v.y = accumarray(subs,v.y,varargin{:});
v.z = accumarray(subs,v.z,varargin{:});

v.isNormalized = false;