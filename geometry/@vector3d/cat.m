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

    % indices are comparable only within one crystal frame, and one list is
    % written in one convention
    if isCrystalDirection(v) && isCrystalDirection(vs)

      if vs.CS ~= v.CS
        error('I can not store Miller indices with respect to different crystal symmetries within one list');
      end

      if v.dispStyle ~= MillerConvention.xyz && vs.dispStyle ~= MillerConvention.xyz && ...
          MillerConvention(vs.dispStyle) ~= MillerConvention(v.dispStyle)
        warning(['Miller indices are converted to ' char(v.dispStyle)]);
      end
    end
  end
end

v.x = cat(dim,vx{:});
v.y = cat(dim,vy{:});
v.z = cat(dim,vz{:});
