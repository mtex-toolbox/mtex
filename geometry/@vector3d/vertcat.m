function v = vertcat(varargin)
% overloads [v1,v2,v3..]

v = vector3d;

for i = 1:length(varargin)
  v.x = [v.x;varargin{i}.x];
  v.y = [v.y;varargin{i}.y];
  v.z = [v.z;varargin{i}.z];
end

% v.x = vertcat(cell2mat(cellfun(@(v) v.x,varargin,'UniformOutput',false).'));
% v = builtin('vertcat',varargin{:});
% vv.x = vertcat(v.x);
