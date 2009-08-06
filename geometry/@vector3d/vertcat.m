function v = vertcat(varargin)
% overloads [v1,v2,v3..]

vs = repmat(struct(varargin{1}),size(varargin));
for k=1:numel(varargin)
  vs(k) = struct(varargin{k});
end

v = varargin{1};
v.x = vertcat(vs.x);
v.y = vertcat(vs.y);
v.z = vertcat(vs.z);
