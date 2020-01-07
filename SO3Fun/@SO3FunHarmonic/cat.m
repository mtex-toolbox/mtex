function SO3F = cat(dim,varargin)
% overloads cat

% remove emtpy arguments
varargin(cellfun('isempty',varargin)) = [];
SO3F = varargin{1};
bw = SO3F.bandwidth;

for i = 2:numel(varargin)

  bw2 = varargin{i}.bandwidth;
  if bw > bw2
    varargin{i}.bandwidth = bw;
  else
    bw = bw2;
    SO3F.bandwidth = bw2;
  end

  SO3F.fhat = cat(1+dim, SO3F.fhat, varargin{i}.fhat);
end
