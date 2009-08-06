function v = horzcat(varargin)
% overloads [v1,v2,v3..]

vs = repmat(struct(varargin{1}),size(varargin));
for k=1:numel(varargin)
  vs(k) = struct(varargin{k});
end

v = varargin{1};
v.x = horzcat(vs.x);
v.y = horzcat(vs.y);
v.z = horzcat(vs.z);
