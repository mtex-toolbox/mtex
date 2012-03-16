function s = size2str(o)
% convert size to string

s = [];

for i = 1:ndims(o)

  if i>1, s = [s,' x '];end
  s = [s,num2str(size(o,i))];
  
end

