function v = vertcat(varargin)
% overloads [v1,v2,v3..]

v = varargin{1};

for i = 1:numel(varargin)
  vs(i).x = varargin{i}.x;
  vs(i).y = varargin{i}.y;
  vs(i).z = varargin{i}.z;
end

v.x = vertcat(vs.x);
v.y = vertcat(vs.y);
v.z = vertcat(vs.z);
