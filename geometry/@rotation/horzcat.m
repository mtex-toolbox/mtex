function rot = horzcat(varargin)
% implements [rot1,rot2,rot3..]

% preallocation
rots = repmat(struct(varargin{1}),size(varargin));

% copy cell content
for k=1:numel(varargin)
  rots(k) = struct(varargin{k});
end

rot = varargin{1};
rot.i = horzcat(rots.i);
rot.quaternion = horzcat(rots.quaternion);
