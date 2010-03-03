function c = repcell(v,varargin)
% equivalent to repmat for cells

c = cell(varargin{:});
c(:) = {v};
