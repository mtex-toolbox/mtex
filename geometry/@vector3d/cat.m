function v = cat(dim,varargin)
% implement cat for vector3d
%
% Syntax 
%   v = cat(dim,v1,v2,v3)
%
% Input
%  dim - dimension
%  v1, v2, v3 - @vector3d
%
% Output
%  v - @vector3d
%
% See also
% vector3d/horzcat, vector3d/vertcat


% remove emtpy arguments
varargin(cellfun('isempty',varargin)) = [];
v = varargin{1};

vx = cell(size(varargin)); vy = vx; vz = vx;
for i = 1:numel(varargin)
  vs = varargin{i};
  if ~isempty(vs)
    vx{i} = vs.x;
    vy{i} = vs.y;
    vz{i} = vs.z;
    v.isNormalized = v.isNormalized & vs.isNormalized;
  end
end

v.x = cat(dim,vx{:});
v.y = cat(dim,vy{:});
v.z = cat(dim,vz{:});
