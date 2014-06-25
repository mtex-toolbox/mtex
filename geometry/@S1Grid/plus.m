function c = plus(a,b)
% 

if isa(a,'S1Grid') 
  c = a;
  a = {a.points};
  b = repcell(b,size(a));
elseif isa(b,'S1Grid')   
  c = b;
  a = repcell(a,size(b));
  b = {b.points};
end

for i = 1:length(c)
  
  c(i).points = a{i} + b{i};
  
end
