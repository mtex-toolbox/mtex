function m = vertcat(varargin)
% overloads [m1;m2;m3..]

m = varargin{1};
for i = 2:numel(varargin)
  m.vector3d = vertcat(m.vector3d,varargin{i}.vector3d);
end
