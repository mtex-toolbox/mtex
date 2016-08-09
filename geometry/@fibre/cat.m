function f = cat(dim,varargin)
% 

% remove emtpy arguments
varargin(cellfun('isempty',varargin)) = [];
f = varargin{1};

fh = cell(size(varargin)); fr = fh;
for i = 1:numel(varargin)
  f2 = varargin{i};
  if ~isempty(f2)
    fh{i} = f2.h;
    fr{i} = f2.r;
  end
end

f.h = cat(dim,fh{:});
f.r = cat(dim,fr{:});
