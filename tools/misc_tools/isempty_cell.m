function e = isempty_cell(c)
% isempty for cells

e = all(cellfun('isempty',c));
