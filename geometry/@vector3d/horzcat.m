function v = horzcat(varargin)
% overloads [v1,v2,v3..]

v = varargin{1};

for i = 1:numel(varargin)
  vs(i).x = varargin{i}.x;
  vs(i).y = varargin{i}.y;
  vs(i).z = varargin{i}.z;
end

v.x = horzcat(vs.x);
v.y = horzcat(vs.y);
v.z = horzcat(vs.z);
