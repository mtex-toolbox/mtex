function r = horzcat(varargin)
% implements [r1,r2,r3..]

r = varargin{1};

inv = cell(size(varargin));
quat = cell(size(varargin));
for i = 1:numel(varargin)
  iinv = varargin{i}.inversion;
  if isempty(iinv)
    inv{i} = ones(size(varargin{i}));
  else
    inv{i} = iinv;
  end 
  quat{i} = quaternion(varargin{i});
end

r.quaternion = horzcat(quat{:});
r.inversion = horzcat(inv{:});
