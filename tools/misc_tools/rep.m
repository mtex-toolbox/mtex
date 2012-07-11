function l = rep(a,b)
% implements R like "rep" elementeweise

s = [1,cumsum(b)+1];
l = repmat(0,[1 s(end)-1]);
for i = 1:length(b)
    l(s(i):s(i+1)-1) = repmat(a(i),[1 b(i)]);
end
    
