function v = cat(dim,varargin)
% 

% remove emtpy arguments
varargin(cellfun('isempty',varargin)) = [];
v = varargin{1};

vx = cell(size(varargin)); vy = vx; vz = vx;
for i = 1:numel(varargin)
  vs = varargin{i};
  if ~isempty(vs)
    vx{i} = vs.x;
    vy{i} = vs.y;
    vz{i} = vs.z;
  end
end

v.x = cat(dim,vx{:});
v.y = cat(dim,vy{:});
v.z = cat(dim,vz{:});
