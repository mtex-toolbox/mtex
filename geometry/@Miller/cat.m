function m = cat(dim,varargin)
% concatenate lists of Miller indices to one list

% remove emtpy arguments
varargin(cellfun('isempty',varargin)) = [];

m = varargin{1};

vx = cell(size(varargin)); vy = vx; vz = vx;
for i = 1:numel(varargin)
  ms = varargin{i};
  if ~isempty(ms)
    vx{i} = ms.x;
    vy{i} = ms.y;
    vz{i} = ms.z;
    if ms.CS ~= m.CS
      error('I can not store Miller indices with respect to different crystal symmetries within one list');
    end
    
    if MillerConvention(ms.dispStyle) ~= MillerConvention(m.dispStyle)
      warning(['Miller indices are converted to ' char(m.dispStyle)]);
    end
  end
end

m.x = cat(dim,vx{:});
m.y = cat(dim,vy{:});
m.z = cat(dim,vz{:});

% ensure all arguments have same symmetry
