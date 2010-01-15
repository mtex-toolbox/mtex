function o = vertcat(varargin)
% implements [o1;o2;o3..]

% preallocation
os = repmat(struct(varargin{1}),size(varargin));

% copy cell content
for k=1:numel(varargin)
  os(k) = struct(varargin{k});
end

o = varargin{1};
o.i = vertcat(os.i);
o.quaternion = vertcat(os.quaternion);
