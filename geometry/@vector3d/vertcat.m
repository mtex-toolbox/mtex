function v = vertcat(varargin)
% overloads [v1,v2,v3..]

v = varargin{1};

vx = cell(size(varargin)); vy = vx; vz = vy;
for i = 1:numel(varargin)
  vv = varargin{i};
  vx{i} = vv.x;
  vy{i} = vv.y;
  vz{i} = vv.z;
end

v.x = vertcat(vx{:});
v.y = vertcat(vy{:});
v.z = vertcat(vz{:});
