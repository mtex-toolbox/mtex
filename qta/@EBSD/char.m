function s = char(ebsd)
% ebsd -> char

s = {};

for n=1:numel(ebsd)
  so3 = ebsd.orientations(n);
  s = {s{:},  [char(getCSym(so3)) '/' char(getSSym(so3)) ': ' char(so3)]};
end

s = char(s');