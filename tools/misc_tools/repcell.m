function c = repcell(v,s)
% equivalent to repmat for cells

c = cell(s);
c(:) = {v};
