function o = horzcat(varargin)
% implements [o1,o2,o3..]


% preallocation
os = repmat(struct(varargin{1}),size(varargin));

% copy cell content
for k=1:numel(varargin)
  os(k) = struct(varargin{k});
end

o = varargin{1};
o.i = horzcat(os.i);
o.quaternion = horzcat(os.quaternion);
