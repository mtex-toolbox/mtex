function s = size2str(o)
% convert size to string

s = [];

for i = 1:length(size(o)) % ndims(o) not works pretty well if size/length are new functions

  if i>1, s = [s,' x '];end
  s = [s,num2str(size(o,i))];
  
end

