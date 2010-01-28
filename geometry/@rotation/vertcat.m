function rot = vertcat(varargin)
% implements [rot1;rot2;rot3..]

% preallocation
rots = repmat(struct(varargin{1}),size(varargin));

% copy cell content
for k=1:numel(varargin)
  rots(k) = struct(varargin{k});
end

rot = varargin{1};
rot.i = vertcat(rots.i);
rot.quaternion = vertcat(rots.quaternion);
