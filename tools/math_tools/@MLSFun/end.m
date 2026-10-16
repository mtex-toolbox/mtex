function e = end(F,i,n)
% overloads end

s = size(F.values);
if n == 1
  e = prod(s(2:end));
else
  e = s(i+1);
end

end
