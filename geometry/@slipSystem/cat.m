function sS = cat(dim,varargin)
% 

% remove emtpy arguments
varargin(cellfun('isempty',varargin)) = [];
sS = varargin{1};

sSb = cell(size(varargin)); sSd = sSb; vz = sSb;
for i = 1:numel(varargin)
  sS2 = varargin{i};
  if ~isempty(sS2)
    sSb{i} = sS2.b;
    sSd{i} = sS2.d;
  end
end

sS.b = cat(dim,sSb{:});
sS.d = cat(dim,sSd{:});

