function v = horzcat(varargin)
% overloads [v1,v2,v3..]

v = vector3d;

for i = 1:length(varargin)
    v.x = [v.x,varargin{i}.x];
    v.y = [v.y,varargin{i}.y];
    v.z = [v.z,varargin{i}.z];
end
